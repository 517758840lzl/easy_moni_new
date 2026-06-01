import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ToastPosition {
  const ToastPosition({this.align = Alignment.center, this.offset = 10.0});

  final AlignmentGeometry align;
  final double offset;

  static const ToastPosition center = ToastPosition();

  static const ToastPosition bottom =
      ToastPosition(align: Alignment.bottomCenter, offset: -30.0);

  static const ToastPosition top =
      ToastPosition(align: Alignment.topCenter, offset: 75.0);

  ToastPosition copyWith({AlignmentGeometry? align, double? offset}) {
    return ToastPosition(
      align: align ?? this.align,
      offset: offset ?? this.offset,
    );
  }

  @override
  String toString() => 'ToastPosition(align: $align, offset: $offset)';
}

// ---------- typedef ----------
typedef EasyToastAnimationBuilder = Widget Function(
  BuildContext context,
  Widget child,
  AnimationController controller,
  double percent,
);

typedef BuildContextPredicate = BuildContext Function(
  Iterable<BuildContext> list,
);


Widget _defaultBuildAnimation(
  BuildContext context,
  Widget child,
  AnimationController controller,
  double percent,
) {
  return Opacity(opacity: percent, child: child);
}

const Duration _defaultEasyDuration = Duration(milliseconds: 2300);
const Duration _defaultAnimDuration = Duration(milliseconds: 250);
const Color _defaultBackgroundColor = Color(0xDD000000);
const EdgeInsets _defaultTextPadding = EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 10,
);

const TextStyle _defaultTextStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.normal,
  color: Colors.white,
);

BuildContext _defaultContextPredicate(Iterable<BuildContext> list) {
  return list.first;
}

// ---------- ToastTheme ----------
class ToastTheme extends InheritedWidget {
  const ToastTheme({
    required super.child,
    super.key,
    this.backgroundColor = _defaultBackgroundColor,
    this.radius = 10.0,
    this.position = ToastPosition.center,
    this.duration = _defaultEasyDuration,
    this.animationDuration = _defaultAnimDuration,
    this.animationCurve = Curves.easeIn,
    this.textDirection = TextDirection.ltr,
    this.textStyle = _defaultTextStyle,
    this.handleTouch = false,
    this.dismissOtherOnShow = true,
    this.movingOnWindowChange = true,
    this.textPadding,
    this.textAlign,
    this.textMaxLines,
    this.textOverflow,
    this.animationBuilder = _defaultBuildAnimation,
  });

  final Color? backgroundColor;
  final double? radius;
  final ToastPosition position;
  final Duration duration;
  final Duration animationDuration;
  final Curve animationCurve;
  final TextDirection textDirection;
  final TextStyle textStyle;
  final bool handleTouch;
  final bool dismissOtherOnShow;
  final bool movingOnWindowChange;
  final EdgeInsetsGeometry? textPadding;
  final TextAlign? textAlign;
  final int? textMaxLines;
  final TextOverflow? textOverflow;
  final EasyToastAnimationBuilder animationBuilder;

  static ToastTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<ToastTheme>();
    return theme ?? const ToastTheme(child: SizedBox());
  }

  @override
  bool updateShouldNotify(ToastTheme oldWidget) => true;
}

// ---------- context map ----------
final LinkedHashMap<_EasyToastState, BuildContext> _contextMap =
    LinkedHashMap<_EasyToastState, BuildContext>();
final Map<_EasyToastState, GlobalKey<OverlayState>> _overlayKeyMap =
    {};

// ---------- EasyToast widget ----------

class EasyToast extends StatefulWidget {
  const EasyToast({
    super.key,
    required this.child,
    this.textDirection = TextDirection.ltr,
    this.dismissOtherOnShow = true,
    this.movingOnWindowChange = true,
    this.position = ToastPosition.center,
    this.duration = _defaultEasyDuration,
    this.animationDuration = _defaultAnimDuration,
    this.animationCurve = Curves.easeIn,
    this.animationBuilder = _defaultBuildAnimation,
    this.backgroundColor = _defaultBackgroundColor,
    this.radius = 10.0,
    this.handleTouch = false,
    this.textStyle = _defaultTextStyle,
    this.textPadding,
    this.textAlign,
    this.textMaxLines,
    this.textOverflow,
  });

  final Widget child;
  final TextDirection textDirection;
  final bool dismissOtherOnShow;
  final bool movingOnWindowChange;
  final ToastPosition position;
  final Duration duration;
  final Duration animationDuration;
  final Curve animationCurve;
  final EasyToastAnimationBuilder animationBuilder;
  final Color? backgroundColor;
  final double? radius;
  final bool handleTouch;
  final TextStyle textStyle;
  final EdgeInsetsGeometry? textPadding;
  final TextAlign? textAlign;
  final int? textMaxLines;
  final TextOverflow? textOverflow;

  @override
  State<EasyToast> createState() => _EasyToastState();
}

class _EasyToastState extends State<EasyToast> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    _contextMap[this] = context;
    _overlayKeyMap[this] = _overlayKey;
  }

  @override
  void dispose() {
    _contextMap.remove(this);
    _overlayKeyMap.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastTheme(
      backgroundColor: widget.backgroundColor,
      radius: widget.radius,
      position: widget.position,
      duration: widget.duration,
      animationDuration: widget.animationDuration,
      animationCurve: widget.animationCurve,
      textDirection: widget.textDirection,
      textStyle: widget.textStyle,
      handleTouch: widget.handleTouch,
      dismissOtherOnShow: widget.dismissOtherOnShow,
      movingOnWindowChange: widget.movingOnWindowChange,
      textPadding: widget.textPadding,
      textAlign: widget.textAlign,
      textMaxLines: widget.textMaxLines,
      textOverflow: widget.textOverflow,
      animationBuilder: widget.animationBuilder,
      child: Directionality(
        textDirection: widget.textDirection,
        child: Overlay(
          key: _overlayKey,
          initialEntries: [
            OverlayEntry(builder: (ctx) => widget.child),
          ],
        ),
      ),
    );
  }
}


ToastFuture showToast(
  String msg, {
  BuildContext? context,
  BuildContextPredicate buildContextPredicate = _defaultContextPredicate,
  Duration? duration,
  ToastPosition? position,
  Color? backgroundColor,
  double? radius,
  VoidCallback? onDismiss,
  bool? dismissOtherToast,
  EasyToastAnimationBuilder? animationBuilder,
  Duration? animationDuration,
  Curve? animationCurve,
  BoxConstraints? constraints,
  EdgeInsetsGeometry? margin = const EdgeInsets.all(50),
  TextDirection? textDirection,
  EdgeInsetsGeometry? textPadding,
  TextAlign? textAlign,
  TextStyle? textStyle,
  int? textMaxLines,
  TextOverflow? textOverflow,
}) {
  if (context == null) {
    _throwIfNoContext(_contextMap.values, 'showToast');
  }
  context ??= buildContextPredicate(_contextMap.values);

  final ToastTheme theme = ToastTheme.of(context);
  position ??= theme.position;
  backgroundColor ??= theme.backgroundColor;
  radius ??= theme.radius;
  textDirection ??= theme.textDirection;
  textPadding ??= theme.textPadding ?? _defaultTextPadding;
  textAlign ??= theme.textAlign;
  textStyle ??= theme.textStyle;
  textMaxLines ??= theme.textMaxLines;
  textOverflow ??= theme.textOverflow;

  final Widget widget = Container(
    constraints: constraints,
    margin: margin,
    padding: textPadding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius ?? 10),
      color: backgroundColor,
    ),
    child: ClipRect(
      child: Text(
        msg,
        style: textStyle,
        textAlign: textAlign,
        maxLines: textMaxLines,
        overflow: textOverflow,
      ),
    ),
  );

  return showToastWidget(
    widget,
    context: context,
    buildContextPredicate: buildContextPredicate,
    duration: duration,
    onDismiss: onDismiss,
    position: position,
    dismissOtherToast: dismissOtherToast,
    textDirection: textDirection,
    animationBuilder: animationBuilder,
    animationDuration: animationDuration,
    animationCurve: animationCurve,
  );
}

// ---------- showToastWidget ----------
ToastFuture showToastWidget(
  Widget widget, {
  BuildContext? context,
  BuildContextPredicate buildContextPredicate = _defaultContextPredicate,
  Duration? duration,
  ToastPosition? position,
  VoidCallback? onDismiss,
  bool? dismissOtherToast,
  TextDirection? textDirection,
  bool? handleTouch,
  EasyToastAnimationBuilder? animationBuilder,
  Duration? animationDuration,
  Curve? animationCurve,
}) {
  if (context == null) {
    _throwIfNoContext(_contextMap.values, 'showToastWidget');
  }
  context ??= buildContextPredicate(_contextMap.values);

  final ToastTheme theme = ToastTheme.of(context);
  position ??= theme.position;
  handleTouch ??= theme.handleTouch;
  animationBuilder ??= theme.animationBuilder;
  animationDuration ??= theme.animationDuration;
  animationCurve ??= theme.animationCurve;
  duration ??= theme.duration;

  final bool movingOnWindowChange = theme.movingOnWindowChange;
  final TextDirection direction = textDirection ?? theme.textDirection;

  final GlobalKey<_ToastContainerState> key = GlobalKey();

  widget = Align(alignment: position.align, child: widget);

  final OverlayEntry entry = OverlayEntry(
    builder: (BuildContext ctx) {
      return IgnorePointer(
        ignoring: !(handleTouch ?? false),
        child: Directionality(
          textDirection: direction,
          child: ToastContainer(
            key: key,
            duration: duration ?? _defaultEasyDuration,
            position: position ?? ToastPosition.center,
            movingOnWindowChange: movingOnWindowChange,
            animationBuilder: animationBuilder ?? _defaultBuildAnimation,
            animationDuration: animationDuration ?? _defaultAnimDuration,
            animationCurve: animationCurve ?? Curves.easeIn,
            child: widget,
          ),
        ),
      );
    },
  );

  dismissOtherToast ??= theme.dismissOtherOnShow;

  if (dismissOtherToast == true) {
    ToastManager().dismissAll();
  }

  final ToastFuture future = ToastFuture._(
    entry,
    onDismiss,
    key,
    animationDuration,
  );

  if (duration != Duration.zero) {
    future.timer = Timer(duration, () {
      future.dismiss();
    });
  }

  ToastManager().addFuture(future);

  void insertOverlayEntry() {
    if (!future.dismissed) {
      future._insertEntry(context!);
    }
  }

  if (SchedulerBinding.instance.schedulerPhase !=
      SchedulerPhase.persistentCallbacks) {
    insertOverlayEntry();
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      insertOverlayEntry();
    });
  }

  return future;
}

void dismissAllToast({bool showAnim = false}) {
  ToastManager().dismissAll(showAnim: showAnim);
}

void _throwIfNoContext(Iterable<BuildContext> contexts, String methodName) {
  if (contexts.isNotEmpty) return;
  throw FlutterError(
    'No EasyToast widget found.\n'
    '$methodName requires an EasyToast widget ancestor.',
  );
}

class ToastFuture {
  ToastFuture._(
    this._entry,
    this._onDismiss,
    this._containerKey,
    this.animationDuration,
  ) {
    _entry.addListener(_mountedListener);
  }

  final OverlayEntry _entry;
  final VoidCallback? _onDismiss;
  final GlobalKey<_ToastContainerState> _containerKey;
  final Duration animationDuration;

  Timer? timer;
  bool _isShow = false;
  bool _dismissed = false;
  bool _isEntryInserted = false;

  bool get mounted => _isShow;
  bool get dismissed => _dismissed;

  void _mountedListener() {
    _isShow = _entry.mounted;
  }

  void _insertEntry(BuildContext context) {
    OverlayState? state;
    for (final key in _overlayKeyMap.values) {
      state = key.currentState;
      if (state != null) break;
    }
    state ??= Overlay.of(context);
    _isEntryInserted = state != null;
    state?.insert(_entry);
  }

  void _removeEntry() {
    _entry.removeListener(_mountedListener);
    if (_isEntryInserted) {
      _entry.remove();
    }
  }

  void dismiss({bool showAnim = false}) {
    if (!_isShow) {
      ToastManager().removeFuture(this);
      timer?.cancel();
      _dismissed = true;
      _removeEntry();
      return;
    }

    _isShow = false;
    _onDismiss?.call();
    ToastManager().removeFuture(this);

    if (showAnim) {
      _containerKey.currentState?.showDismissAnim();
      Future<void>.delayed(animationDuration, _removeEntry);
    } else {
      _removeEntry();
    }

    timer?.cancel();
    _dismissed = true;
  }
}

// ---------- ToastManager ----------
class ToastManager {
  factory ToastManager() => _instance;
  ToastManager._();
  static final ToastManager _instance = ToastManager._();

  final Set<ToastFuture> toastSet = <ToastFuture>{};

  void dismissAll({bool showAnim = false}) {
    toastSet.toList().forEach((ToastFuture v) {
      v.dismiss(showAnim: showAnim);
    });
  }

  void removeFuture(ToastFuture future) => toastSet.remove(future);
  void addFuture(ToastFuture future) => toastSet.add(future);
}

// ---------- ToastContainer ----------
class ToastContainer extends StatefulWidget {
  const ToastContainer({
    super.key,
    required this.child,
    required this.duration,
    required this.position,
    required this.movingOnWindowChange,
    required this.animationBuilder,
    required this.animationDuration,
    required this.animationCurve,
  });

  final Widget child;
  final Duration duration;
  final ToastPosition position;
  final bool movingOnWindowChange;
  final EasyToastAnimationBuilder animationBuilder;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<ToastContainer> createState() => _ToastContainerState();
}

class _ToastContainerState extends State<ToastContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showDismissAnim() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pos = widget.position;

    return Padding(
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top,
        bottom: mediaQuery.padding.bottom,
      ),
      child: Align(
        alignment: pos.align,
        child: Padding(
          padding: EdgeInsets.only(
            top: pos.align == Alignment.topCenter ? pos.offset : 10,
            bottom: pos.align == Alignment.bottomCenter ? -pos.offset : 10,
          ),
          child: widget.animationBuilder(
            context,
            widget.child,
            _animationController,
            _animation.value,
          ),
        ),
      ),
    );
  }
}
