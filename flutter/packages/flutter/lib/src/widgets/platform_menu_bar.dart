// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'binding.dart';
import 'framework.dart';
import 'shortcuts.dart';

// "flutter/menu" Method channel methods.
const String _kMenuSetMethod = 'Menu.setMenu';
const String _kMenuSelectedCallbackMethod = 'Menu.selectedCallback';
const String _kMenuItemOpenedMethod = 'Menu.opened';
const String _kMenuItemClosedMethod = 'Menu.closed';

// Keys for channel communication map.
const String _kIdKey = 'id';
const String _kLabelKey = 'label';
const String _kEnabledKey = 'enabled';
const String _kChildrenKey = 'children';
const String _kIsDividerKey = 'isDivider';
const String _kPlatformDefaultMenuKey = 'platformProvidedMenu';

/// A class used by [MenuSerializableShortcut] to describe the shortcut for
/// serialization to send to the platform for rendering a [PlatformMenuBar].
///
/// See also:
///
///  * [PlatformMenuBar], a widget that defines a menu bar for the platform to
///    render natively.
///  * [MenuSerializableShortcut], a mixin allowing a [ShortcutActivator] to
///    provide data for serialization of the shortcut for sending to the
///    platform.
class ShortcutSerialization {
  /// Creates a [ShortcutSerialization] representing a single character.
  ///
  /// This is used by a [CharacterActivator] to serialize itself.
  ShortcutSerialization.character(String character)
      : _internal = <String, Object?>{_shortcutCharacter: character},
        assert(character.length == 1);

  /// Creates a [ShortcutSerialization] representing a specific
  /// [LogicalKeyboardKey] and modifiers.
  ///
  /// This is used by a [SingleActivator] to serialize itself.
  ShortcutSerialization.modifier(
    LogicalKeyboardKey trigger, {
    bool control = false,
    bool shift = false,
    bool alt = false,
    bool meta = false,
  })  : assert(trigger != LogicalKeyboardKey.shift &&
               trigger != LogicalKeyboardKey.shiftLeft &&
               trigger != LogicalKeyboardKey.shiftRight &&
               trigger != LogicalKeyboardKey.alt &&
               trigger != LogicalKeyboardKey.altLeft &&
               trigger != LogicalKeyboardKey.altRight &&
               trigger != LogicalKeyboardKey.control &&
               trigger != LogicalKeyboardKey.controlLeft &&
               trigger != LogicalKeyboardKey.controlRight &&
               trigger != LogicalKeyboardKey.meta &&
               trigger != LogicalKeyboardKey.metaLeft &&
               trigger != LogicalKeyboardKey.metaRight,
               'Specifying a modifier key as a trigger is not allowed. '
               'Use provided boolean parameters instead.'),
        _internal = <String, Object?>{
          _shortcutTrigger: trigger.keyId,
          _shortcutModifiers: (control ? _shortcutModifierControl : 0) |
              (alt ? _shortcutModifierAlt : 0) |
              (shift ? _shortcutModifierShift : 0) |
              (meta ? _shortcutModifierMeta : 0),
        };

  final Map<String, Object?> _internal;

  /// The bit mask for the [LogicalKeyboardKey.meta] key (or it's left/right
  /// equivalents) being down.
  static const int _shortcutModifierMeta = 1 << 0;

  /// The bit mask for the [LogicalKeyboardKey.shift] key (or it's left/right
  /// equivalents) being down.
  static const int _shortcutModifierShift = 1 << 1;

  /// The bit mask for the [LogicalKeyboardKey.alt] key (or it's left/right
  /// equivalents) being down.
  static const int _shortcutModifierAlt = 1 << 2;

  /// The bit mask for the [LogicalKeyboardKey.alt] key (or it's left/right
  /// equivalents) being down.
  static const int _shortcutModifierControl = 1 << 3;

  /// The key for a string map field returned from [serializeForMenu] containing
  /// a string that represents the character that, when typed, will trigger the
  /// shortcut.
  ///
  /// All platforms are limited to a single trigger key that can be represented,
  /// so this string should only contain a character that can be typed with a
  /// single keystroke.
  static const String _shortcutCharacter = 'shortcutEquivalent';

  /// The key for the integer map field returned from [serializeForMenu]
  /// containing the logical key ID for the trigger key on this shortcut.
  ///
  /// All platforms are limited to a single trigger key that can be represented.
  static const String _shortcutTrigger = 'shortcutTrigger';

  /// The key for the integer map field returned from [serializeForMenu]
  /// containing a bitfield combination of [shortcutModifierControl],
  /// [shortcutModifierAlt], [shortcutModifierShift], and/or
  /// [shortcutModifierMeta].
  ///
  /// If the shortcut responds to one of those modifiers, it should be
  /// represented in the bitfield tagged with this key.
  static const String _shortcutModifiers = 'shortcutModifiers';

  /// Converts the internal representation to the format needed for a [MenuItem]
  /// to include it in its serialized form for sending to the platform.
  Map<String, Object?> toChannelRepresentation() => _internal;
}

/// A mixin allowing a [ShortcutActivator] to provide data for serialization of
/// the shortcut when sending to the platform.
///
/// This is meant for those who have written their own [ShortcutActivator]
/// subclass, and would like to have it work for menus in a [PlatformMenuBar] as
/// well.
///
/// Keep in mind that there are limits to the capabilities of the platform APIs,
/// and not all kinds of [ShortcutActivator]s will work with them.
///
/// See also:
///
///  * [SingleActivator], a [ShortcutActivator] which implements this mixin.
///  * [CharacterActivator], another [ShortcutActivator] which implements this mixin.
mixin MenuSerializableShortcut {
  /// Implement this in a [ShortcutActivator] subclass to allow it to be
  /// serialized for use in a [PlatformMenuBar].
  ShortcutSerialization serializeForMenu();
}

/// An abstract class for describing cascading menu hierarchies that are part of
/// a [PlatformMenuBar].
///
/// This type is used by [PlatformMenuDelegate.setMenus] to accept the menu
/// hierarchy to be sent to the platform, and by [PlatformMenuBar] to define the
/// menu hierarchy.
///
/// See also:
///
///  * [PlatformMenuBar], a widget that renders menu items using platform APIs
///    instead of Flutter.
abstract class MenuItem with Diagnosticable {
  /// Allows subclasses to have const constructors.
  const MenuItem();

  /// Converts the representation of this item into a map suitable for sending
  /// over the default "flutter/menu" channel used by [DefaultPlatformMenuDelegate].
  ///
  /// The `delegate` is the [PlatformMenuDelegate] that is requesting the
  /// serialization. The `index` is the position of this menu item in the list
  /// of children of the [PlatformMenu] it belongs to, and `count` is the number
  /// of children in the [PlatformMenu] it belongs to.
  ///
  /// The `getId` parameter is a [MenuItemSerializableIdGenerator] function that
  /// generates a unique ID for each menu item, which is to be returned in the
  /// "id" field of the menu item data.
  Iterable<Map<String, Object?>> toChannelRepresentation(
    PlatformMenuDelegate delegate, {
    required int index,
    required int count,
    required MenuItemSerializableIdGenerator getId,
  });

  /// Returns all descendant [MenuItem]s of this item.
  ///
  /// Returns an empty list if this type of menu item doesn't have
  /// descendants.
  List<MenuItem> get descendants => const <MenuItem>[];

  /// Returns a callback, if any, to be invoked if the platform menu receives a
  /// "Menu.selectedCallback" method call from the platform for this item.
  ///
  /// Only items that do not have submenus will have this callback invoked.
  ///
  /// The default implementation returns null.
  VoidCallback? get onSelected => null;

  /// Returns a callback, if any, to be invoked if the platform menu receives a
  /// "Menu.opened" method call from the platform for this item.
  ///
  /// Only items that have submenus will have this callback invokes
  ///
  /// The default implementation returns null.
  VoidCallback? get onOpen => null;

  /// Returns a callback, if any, to be invoked if the platform menu receives a
  /// "Menu.opened" method call from the platform for this item.
  ///
  /// Only items that have submenus will have this callback invoked.
  ///
  /// The default implementation returns null.
  VoidCallback? get onClose => null;
}

/// An abstract delegate class that can be used to set
/// [WidgetsBinding.platformMenuDelegate] to provide for managing platform
/// menus.
///
/// This can be subclassed to provide a different menu plugin than the default
/// system-provided plugin for managing [PlatformMenuBar] menus.
///
/// The [setMenus] method allows for setting of the menu hierarchy when the
/// [PlatformMenuBar] menu hierarchy changes.
///
/// This delegate doesn't handle the results of clicking on a menu item, which
/// is left to the implementor of subclasses of `PlatformMenuDelegate` to
/// handle for their implementation.
///
/// This delegate typically knows how to serialize a [PlatformMenu]
/// hierarchy, send it over a channel, and register for calls from the channel
/// when a menu is invoked or a submenu is opened or closed.
///
/// See [DefaultPlatformMenuDelegate] for an example of implementing one of
/// these.
///
/// See also:
///
///  * [PlatformMenuBar], the widget that adds a platform menu bar to an
///    application, and uses [setMenus] to send the menus to the platform.
///  * [PlatformMenu], the class that describes a menu item with children
///    that appear in a cascading menu.
///  * [PlatformMenuItem], the class that describes the leaves of a menu
///    hierarchy.
abstract class PlatformMenuDelegate {
  /// A const constructor so that subclasses can have const constructors.
  const PlatformMenuDelegate();

  /// Sets the entire menu hierarchy for a platform-rendered menu bar.
  ///
  /// The `topLevelMenus` argument is the list of menus that appear in the menu
  /// bar, which themselves can have children.
  ///
  /// To update the menu hierarchy or menu item state, call `setMenus` with the
  /// modified hierarchy, and it will overwrite the previous menu state.
  ///
  /// See also:
  ///
  ///  * [PlatformMenuBar], the widget that adds a platform menu bar to an
  ///    application.
  ///  * [PlatformMenu], the class that describes a menu item with children
  ///    that appear in a cascading menu.
  ///  * [PlatformMenuItem], the class that describes the leaves of a menu
  ///    hierarchy.
  void setMenus(List<MenuItem> topLevelMenus);

  /// Clears any existing platform-rendered menus and leaves the application
  /// with no menus.
  ///
  /// It is not necessary to call this before updating the menu with [setMenus].
  void clearMenus();

  /// This is called by [PlatformMenuBar] when it is initialized, to be sure that
  /// only one is active at a time.
  ///
  /// The `debugLockDelegate` function should be called before the first call to
  /// [setMenus].
  ///
  /// If the lock is successfully acquired, `debugLockDelegate` will return
  /// true.
  ///
  /// If your implementation of a [PlatformMenuDelegate] can have only limited
  /// active instances, enforce it when you override this function.
  ///
  /// See also:
  ///
  ///  * [debugUnlockDelegate], where the delegate is unlocked.
  bool debugLockDelegate(BuildContext context);

  /// This is called by [PlatformMenuBar] when it is disposed, so that another
  /// one can take over.
  ///
  /// If the `debugUnlockDelegate` successfully unlocks the delegate, it will
  /// return true.
  ///
  /// See also:
  ///
  ///  * [debugLockDelegate], where the delegate is locked.
  bool debugUnlockDelegate(BuildContext context);
}

/// The signature for a function that generates unique menu item IDs for
/// serialization of a [MenuItem].
typedef MenuItemSerializableIdGenerator = int Function(MenuItem item);

/// The platform menu delegate that handles the built-in macOS platform menu
/// generation using the 'flutter/menu' channel.
///
/// An instance of this class is set on [WidgetsBinding.platformMenuDelegate] by
/// default when the [WidgetsBinding] is initialized.
///
/// See also:
///
///  * [PlatformMenuBar], the widget that adds a platform menu bar to an
///    application.
///  * [PlatformMenu], the class that describes a menu item with children
///    that appear in a cascading menu.
///  * [PlatformMenuItem], the class that describes the leaves of a menu
///    hierarchy.
class DefaultPlatformMenuDelegate extends PlatformMenuDelegate {
  /// Creates a const [DefaultPlatformMenuDelegate].
  ///
  /// The optional [channel] argument defines the channel used to communicate
  /// with the platform. It defaults to [SystemChannels.menu] if not supplied.
  DefaultPlatformMenuDelegate({MethodChannel? channel})
      : channel = channel ?? SystemChannels.menu,
        _idMap = <int, MenuItem>{} {
    this.channel.setMethodCallHandler(_methodCallHandler);
  }

  // Map of distributed IDs to menu items.
  final Map<int, MenuItem> _idMap;
  // An ever increasing value used to dole out IDs.
  int _serial = 0;
  // The context used to "lock" this delegate to a specific instance of
  // PlatformMenuBar to make sure there is only one.
  BuildContext? _lockedContext;

  @override
  void clearMenus() => setMenus(<MenuItem>[]);

  @override
  void setMenus(List<MenuItem> topLevelMenus) {
    _idMap.clear();
    final List<Map<String, Object?>> representation = <Map<String, Object?>>[];
    if (topLevelMenus.isNotEmpty) {
      int index = 0;
      for (final MenuItem childItem in topLevelMenus) {
        representation
            .addAll(childItem.toChannelRepresentation(this, index: index, count: topLevelMenus.length, getId: _getId));
        index += 1;
      }
    }
    // Currently there's only ever one window, but the channel's format allows
    // more than one window's menu hierarchy to be defined.
    final Map<String, Object?> windowMenu = <String, Object?>{
      '0': representation,
    };
    channel.invokeMethod<void>(_kMenuSetMethod, windowMenu);
  }

  /// Defines the channel that the [DefaultPlatformMenuDelegate] uses to
  /// communicate with the platform.
  ///
  /// Defaults to [SystemChannels.menu].
  final MethodChannel channel;

  /// Get the next serialization ID.
  ///
  /// This is called by each DefaultPlatformMenuDelegateSerializer when
  /// serializing a new object so that it has a unique ID.
  int _getId(MenuItem item) {
    _serial += 1;
    _idMap[_serial] = item;
    return _serial;
  }

  @override
  bool debugLockDelegate(BuildContext context) {
    assert(() {
      // It's OK to lock if the lock isn't set, but not OK if a different
      // context is locking it.
      if (_lockedContext != null && _lockedContext != context) {
        return false;
      }
      _lockedContext = context;
      return true;
    }());
    return true;
  }

  @override
  bool debugUnlockDelegate(BuildContext context) {
    assert(() {
      // It's OK to unlock if the lock isn't set, but not OK if a different
      // context is unlocking it.
      if (_lockedContext != null && _lockedContext != context) {
        return false;
      }
      _lockedContext = null;
      return true;
    }());
    return true;
  }

  // Handles the method calls from the plugin to forward to selection and
  // open/close callbacks.
  Future<void> _methodCallHandler(MethodCall call) async {
    final int id = call.arguments as int;
    assert(
      _idMap.containsKey(id),
      'Received a menu ${call.method} for a menu item with an ID that was not recognized: $id',
    );
    if (!_idMap.containsKey(id)) {
      return;
    }
    final MenuItem item = _idMap[id]!;
    if (call.method == _kMenuSelectedCallbackMethod) {
      item.onSelected?.call();
    } else if (call.method == _kMenuItemOpenedMethod) {
      item.onOpen?.call();
    } else if (call.method == _kMenuItemClosedMethod) {
      item.onClose?.call();
    }
  }
}

/// A menu bar that uses the platform's native APIs to construct and render a
/// menu described by a [PlatformMenu]/[PlatformMenuItem] hierarchy.
///
/// This widget is especially useful on macOS, where a system menu is a required
/// part of every application. Flutter only includes support for macOS out of
/// the box, but support for other platforms may be provided via plugins that
/// set [WidgetsBinding.platformMenuDelegate] in their initialization.
///
/// The [menus] member contains [MenuItem]s. They will not be part of the
/// widget tree, since they are not required to be widgets (even if they happen
/// to be widgets that implement [MenuItem], they still won't be part of the
/// widget tree). They are provided to configure the properties of the menus on
/// the platform menu bar.
///
/// As far as Flutter is concerned, this widget has no visual representation,
/// and intercepts no events: it just returns the [body] from its build
/// function. This is because all of the rendering, shortcuts, and event
/// handling for the menu is handled by the plugin on the host platform.
///
/// There can only be one [PlatformMenuBar] at a time using the same
/// [PlatformMenuDelegate]. It will assert if more than one is detected.
///
/// When calling [toStringDeep] on this widget, it will give a tree of
/// [MenuItem]s, not a tree of widgets.
///
/// {@tool sample}
/// This example shows a [PlatformMenuBar] that contains a single top level
/// menu, containing three items for "About", a toggleable menu item for showing
/// a message, a cascading submenu with message choices, and "Quit".
///
/// **This example will only work on macOS.**
///
/// ** See code in examples/api/lib/material/platform_menu_bar/platform_menu_bar.0.dart **
/// {@end-tool}
class PlatformMenuBar extends StatefulWidget with DiagnosticableTreeMixin {
  /// Creates a const [PlatformMenuBar].
  ///
  /// The [body] and [menus] attributes are required.
  const PlatformMenuBar({
    Key? key,
    required this.body,
    required this.menus,
  }) : super(key: key);

  /// The widget to be rendered in the Flutter window that these platform menus
  /// are associated with.
  ///
  /// This is typically the body of the application's UI.
  final Widget body;

  /// The list of menu items that are the top level children of the
  /// [PlatformMenuBar].
  ///
  /// The `menus` member contains [MenuItem]s. They will not be part
  /// of the widget tree, since they are not widgets. They are provided to
  /// configure the properties of the menus on the platform menu bar.
  ///
  /// Also, a Widget in Flutter is immutable, so directly modifying the
  /// `menus` with `List` APIs such as
  /// `somePlatformMenuBarWidget.menus.add(...)` will result in incorrect
  /// behaviors. Whenever the menus list is modified, a new list object
  /// should be provided.
  final List<MenuItem> menus;

  @override
  State<PlatformMenuBar> createState() => _PlatformMenuBarState();

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return menus.map<DiagnosticsNode>((MenuItem child) => child.toDiagnosticsNode()).toList();
  }
}

class _PlatformMenuBarState extends State<PlatformMenuBar> {
  List<MenuItem> descendants = <MenuItem>[];

  @override
  void initState() {
    super.initState();
    assert(
        WidgetsBinding.instance.platformMenuDelegate.debugLockDelegate(context),
        'More than one active $PlatformMenuBar detected. Only one active '
        'platform-rendered menu bar is allowed at a time.');
    WidgetsBinding.instance.platformMenuDelegate.clearMenus();
    _updateMenu();
  }

  @override
  void dispose() {
    assert(WidgetsBinding.instance.platformMenuDelegate.debugUnlockDelegate(context),
        'tried to unlock the $DefaultPlatformMenuDelegate more than once with context $context.');
    WidgetsBinding.instance.platformMenuDelegate.clearMenus();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlatformMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final List<MenuItem> newDescendants = <MenuItem>[
      for (final MenuItem item in widget.menus) ...<MenuItem>[
        item,
        ...item.descendants,
      ],
    ];
    if (!listEquals(newDescendants, descendants)) {
      descendants = newDescendants;
      _updateMenu();
    }
  }

  // Updates the data structures for the menu and send them to the platform
  // plugin.
  void _updateMenu() {
    WidgetsBinding.instance.platformMenuDelegate.setMenus(widget.menus);
  }

  @override
  Widget build(BuildContext context) {
    // PlatformMenuBar is really about managing the platform menu bar, and
    // doesn't do any rendering or event handling in Flutter.
    return widget.body;
  }
}

/// A class for representing menu items that have child submenus.
///
/// See also:
///
///  * [PlatformMenuItem], a class representing a leaf menu item in a
///    [PlatformMenuBar].
class PlatformMenu extends MenuItem with DiagnosticableTreeMixin {
  /// Creates a const [PlatformMenu].
  ///
  /// The [label] and [menus] fields are required.
  const PlatformMenu({
    required this.label,
    this.onOpen,
    this.onClose,
    required this.menus,
  });

  /// The label that will appear on the menu.
  final String label;

  /// The callback that is called when this menu is opened.
  @override
  final VoidCallback? onOpen;

  /// The callback that is called when this menu is closed.
  @override
  final VoidCallback? onClose;

  /// The menu items in the submenu opened by this menu item.
  ///
  /// If this is an empty list, this [PlatformMenu] will be disabled.
  final List<MenuItem> menus;

  /// Returns all descendant [MenuItem]s of this item.
  @override
  List<MenuItem> get descendants => getDescendants(this);

  /// Returns all descendants of the given item.
  ///
  /// This API is supplied so that implementers of [PlatformMenu] can share
  /// this implementation.
  static List<MenuItem> getDescendants(PlatformMenu item) {
    return <MenuItem>[
      for (final MenuItem child in item.menus) ...<MenuItem>[
        child,
        ...child.descendants,
      ],
    ];
  }

  @override
  Iterable<Map<String, Object?>> toChannelRepresentation(
    PlatformMenuDelegate delegate, {
    required int index,
    required int count,
    required MenuItemSerializableIdGenerator getId,
  }) {
    return <Map<String, Object?>>[serialize(this, delegate, getId)];
  }

  /// Converts the supplied object to the correct channel representation for the
  /// 'flutter/menu' channel.
  ///
  /// This API is supplied so that implementers of [PlatformMenu] can share
  /// this implementation.
  static Map<String, Object?> serialize(
    PlatformMenu item,
    PlatformMenuDelegate delegate,
    MenuItemSerializableIdGenerator getId,
  ) {
    final List<Map<String, Object?>> result = <Map<String, Object?>>[];
    int index = 0;
    for (final MenuItem childItem in item.menus) {
      result.addAll(childItem.toChannelRepresentation(
        delegate,
        index: index,
        count: item.menus.length,
        getId: getId,
      ));
      index += 1;
    }
    return <String, Object?>{
      _kIdKey: getId(item),
      _kLabelKey: item.label,
      _kEnabledKey: item.menus.isNotEmpty,
      _kChildrenKey: result,
    };
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return menus.map<DiagnosticsNode>((MenuItem child) => child.toDiagnosticsNode()).toList();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(FlagProperty('enabled', value: menus.isNotEmpty, ifFalse: 'DISABLED'));
  }
}

/// A class that groups other menu items into sections delineated by dividers.
///
/// Visual dividers will be added before and after this group if other menu
/// items appear in the [PlatformMenu], and the leading one omitted if it is
/// first and the trailing one omitted if it is last in the menu.
class PlatformMenuItemGroup extends MenuItem {
  /// Creates a const [PlatformMenuItemGroup].
  ///
  /// The [members] field is required.
  const PlatformMenuItemGroup({required this.members});

  /// The [MenuItem]s that are members of this menu item group.
  ///
  /// An assertion will be thrown if there isn't at least one member of the group.
  final List<MenuItem> members;

  @override
  Iterable<Map<String, Object?>> toChannelRepresentation(
    PlatformMenuDelegate delegate, {
    required int index,
    required int count,
    required MenuItemSerializableIdGenerator getId,
  }) {
    assert(members.isNotEmpty, 'There must be at least one member in a PlatformMenuItemGroup');
    final List<Map<String, Object?>> result = <Map<String, Object?>>[];
    if (index != 0) {
      result.add(<String, Object?>{
        _kIdKey: getId(this),
        _kIsDividerKey: true,
      });
    }
    for (final MenuItem item in members) {
      result.addAll(item.toChannelRepresentation(
        delegate,
        index: index,
        count: count,
        getId: getId,
      ));
    }
    if (index != count - 1) {
      result.add(<String, Object?>{
        _kIdKey: getId(this),
        _kIsDividerKey: true,
      });
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<MenuItem>('members', members));
  }
}

/// A class for [MenuItem]s that do not have submenus (as a [PlatformMenu]
/// would), but can be selected.
///
/// These [MenuItem]s are the leaves of the menu item tree, and [onSelected]
/// will be called when they are selected by clicking on them, or via an
/// optional keyboard [shortcut].
///
/// See also:
///
///  * [PlatformMenu], a menu item that opens a submenu.
class PlatformMenuItem extends MenuItem {
  /// Creates a const [PlatformMenuItem].
  ///
  /// The [label] attribute is required.
  const PlatformMenuItem({
    required this.label,
    this.shortcut,
    this.onSelected,
  });

  /// The required label used for rendering the menu item.
  final String label;

  /// The optional shortcut that selects this [PlatformMenuItem].
  ///
  /// This shortcut is only enabled when [onSelected] is set.
  final MenuSerializableShortcut? shortcut;

  /// An optional callback that is called when this [PlatformMenuItem] is
  /// selected.
  ///
  /// If unset, this menu item will be disabled.
  @override
  final VoidCallback? onSelected;

  @override
  Iterable<Map<String, Object?>> toChannelRepresentation(
    PlatformMenuDelegate delegate, {
    required int index,
    required int count,
    required MenuItemSerializableIdGenerator getId,
  }) {
    return <Map<String, Object?>>[PlatformMenuItem.serialize(this, delegate, getId)];
  }

  /// Converts the given [PlatformMenuItem] into a data structure accepted by
  /// the 'flutter/menu' method channel method 'Menu.SetMenu'.
  ///
  /// This API is supplied so that implementers of [PlatformMenuItem] can share
  /// this implementation.
  static Map<String, Object?> serialize(
    PlatformMenuItem item,
    PlatformMenuDelegate delegate,
    MenuItemSerializableIdGenerator getId,
  ) {
    final MenuSerializableShortcut? shortcut = item.shortcut;
    return <String, Object?>{
      _kIdKey: getId(item),
      _kLabelKey: item.label,
      _kEnabledKey: item.onSelected != null,
      if (shortcut != null)...shortcut.serializeForMenu().toChannelRepresentation(),
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<MenuSerializableShortcut?>('shortcut', shortcut, defaultValue: null));
    properties.add(FlagProperty('enabled', value: onSelected != null, ifFalse: 'DISABLED'));
  }
}

/// A class that represents a menu item that is provided by the platform.
///
/// This is used to add things like the "About" and "Quit" menu items to a
/// platform menu.
///
/// The [type] enum determines which type of platform defined menu will be
/// added.
///
/// This is most useful on a macOS platform where there are many different types
/// of platform provided menu items in the standard menu setup.
///
/// In order to know if a [PlatformProvidedMenuItem] is available on a
/// particular platform, call [PlatformProvidedMenuItem.hasMenu].
///
/// If the platform does not support the given [type], then the menu item will
/// throw an [ArgumentError] when it is sent to the platform.
///
/// See also:
///
///  * [PlatformMenuBar] which takes these items for inclusion in a
///    platform-rendered menu bar.
class PlatformProvidedMenuItem extends PlatformMenuItem {
  /// Creates a const [PlatformProvidedMenuItem] of the appropriate type. Throws if the
  /// platform doesn't support the given default menu type.
  ///
  /// The [type] argument is required.
  const PlatformProvidedMenuItem({
    required this.type,
    this.enabled = true,
  }) : super(
          label: '', // The label is ignored for standard menus.
        );

  /// The type of default menu this is.
  ///
  /// See [PlatformProvidedMenuItemType] for the different types available. Not
  /// all of the types will be available on every platform. Use [hasMenu] to
  /// determine if the current platform has a given default menu item.
  ///
  /// If the platform does not support the given [type], then the menu item will
  /// throw an [ArgumentError] in debug mode.
  final PlatformProvidedMenuItemType type;

  /// True if this [PlatformProvidedMenuItem] should be enabled or not.
  final bool enabled;

  /// Checks to see if the given default menu type is supported on this
  /// platform.
  static bool hasMenu(PlatformProvidedMenuItemType menu) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.macOS:
        return const <PlatformProvidedMenuItemType>{
          PlatformProvidedMenuItemType.about,
          PlatformProvidedMenuItemType.quit,
          PlatformProvidedMenuItemType.servicesSubmenu,
          PlatformProvidedMenuItemType.hide,
          PlatformProvidedMenuItemType.hideOtherApplications,
          PlatformProvidedMenuItemType.showAllApplications,
          PlatformProvidedMenuItemType.startSpeaking,
          PlatformProvidedMenuItemType.stopSpeaking,
          PlatformProvidedMenuItemType.toggleFullScreen,
          PlatformProvidedMenuItemType.minimizeWindow,
          PlatformProvidedMenuItemType.zoomWindow,
          PlatformProvidedMenuItemType.arrangeWindowsInFront,
        }.contains(menu);
    }
  }

  @override
  Iterable<Map<String, Object?>> toChannelRepresentation(
    PlatformMenuDelegate delegate, {
    required int index,
    required int count,
    required MenuItemSerializableIdGenerator getId,
  }) {
    assert(() {
      if (!hasMenu(type)) {
        throw ArgumentError(
          'Platform ${defaultTargetPlatform.name} has no standard menu for '
          '$type. Call PlatformProvidedMenuItem.hasMenu to determine this before '
          'instantiating one.',
        );
      }
      return true;
    }());

    return <Map<String, Object?>>[
      <String, Object?>{
        _kIdKey: getId(this),
        _kEnabledKey: enabled,
        _kPlatformDefaultMenuKey: type.index,
      },
    ];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'DISABLED'));
  }
}

/// The list of possible standard, prebuilt menus for use in a [PlatformMenuBar].
///
/// These are menus that the platform typically provides that cannot be
/// reproduced in Flutter without calling platform functions, but are standard
/// on the platform.
///
/// Examples include things like the "Quit" or "Services" menu items on macOS.
/// Not all platforms support all menu item types. Use
/// [PlatformProvidedMenuItem.hasMenu] to know if a particular type is supported
/// on a the current platform.
///
/// Add these to your [PlatformMenuBar] using the [PlatformProvidedMenuItem]
/// class.
///
/// You can tell if the platform supports the given standard menu using the
/// [PlatformProvidedMenuItem.hasMenu] method.
// Must be kept in sync with the plugin code's enum of the same name.
enum PlatformProvidedMenuItemType {
  /// The system provided "About" menu item.
  ///
  /// On macOS, this is the `orderFrontStandardAboutPanel` default menu.
  about,

  /// The system provided "Quit" menu item.
  ///
  /// On macOS, this is the `terminate` default menu.
  ///
  /// This menu item will simply exit the application when activated.
  quit,

  /// The system provided "Services" submenu.
  ///
  /// This submenu provides a list of system provided application services.
  ///
  /// This default menu is only supported on macOS.
  servicesSubmenu,

  /// The system provided "Hide" menu item.
  ///
  /// This menu item hides the application window.
  ///
  /// On macOS, this is the `hide` default menu.
  ///
  /// This default menu is only supported on macOS.
  hide,

  /// The system provided "Hide Others" menu item.
  ///
  /// This menu item hides other application windows.
  ///
  /// On macOS, this is the `hideOtherApplications` default menu.
  ///
  /// This default menu is only supported on macOS.
  hideOtherApplications,

  /// The system provided "Show All" menu item.
  ///
  /// This menu item shows all hidden application windows.
  ///
  /// On macOS, this is the `unhideAllApplications` default menu.
  ///
  /// This default menu is only supported on macOS.
  showAllApplications,

  /// The system provided "Start Dictation..." menu item.
  ///
  /// This menu item tells the system to start the screen reader.
  ///
  /// On macOS, this is the `startSpeaking` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  startSpeaking,

  /// The system provided "Stop Dictation..." menu item.
  ///
  /// This menu item tells the system to stop the screen reader.
  ///
  /// On macOS, this is the `stopSpeaking` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  stopSpeaking,

  /// The system provided "Enter Full Screen" menu item.
  ///
  /// This menu item tells the system to toggle full screen mode for the window.
  ///
  /// On macOS, this is the `toggleFullScreen` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  toggleFullScreen,

  /// The system provided "Minimize" menu item.
  ///
  /// This menu item tells the system to minimize the window.
  ///
  /// On macOS, this is the `performMiniaturize` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  minimizeWindow,

  /// The system provided "Zoom" menu item.
  ///
  /// This menu item tells the system to expand the window size.
  ///
  /// On macOS, this is the `performZoom` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  zoomWindow,

  /// The system provided "Bring To Front" menu item.
  ///
  /// This menu item tells the system to stack the window above other windows.
  ///
  /// On macOS, this is the `arrangeInFront` default menu.
  ///
  /// This default menu is currently only supported on macOS.
  arrangeWindowsInFront,
}
