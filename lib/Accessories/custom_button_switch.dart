import 'package:fine_merchant_mobile/theme/FineTheme/index.dart';
import 'package:flutter/cupertino.dart';

class CustomCupertinoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomCupertinoSwitch({required this.value, required this.onChanged});

  @override
  _CustomCupertinoSwitchState createState() => _CustomCupertinoSwitchState();
}

class _CustomCupertinoSwitchState extends State<CustomCupertinoSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _value = !_value;
          widget.onChanged(_value);
        });
      },
      child: Container(
        width: 45.0,
        height: 25.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5),
          color: _value
              ? FineTheme.palettes.primary100
              : CupertinoColors.systemGrey2,
        ),
        child: Stack(
          alignment: _value ? Alignment.centerRight : Alignment.centerLeft,
          children: <Widget>[
            Container(
              width: 22.0,
              height: 22.0,
              margin: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
