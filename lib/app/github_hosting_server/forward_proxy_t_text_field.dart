import 'package:flutter/material.dart';

import '../widgets/core/index.dart';
import 'proxy_services.dart';

class ForwardProxyTTextField extends StatefulWidget {
  TextEditingController controller;
  void Function(String value) onChanged;
  ForwardProxyTTextField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ForwardProxyTTextField> createState() => _ForwardProxyTTextFieldState();
}

class _ForwardProxyTTextFieldState extends State<ForwardProxyTTextField> {
  void _onChooseOnline() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fetch Online'),
        content: SingleChildScrollView(
          child: FutureBuilder(
            future: ProxyServices.getForwardProxyList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return TLoader();
              }
              if (snapshot.hasData) {
                final list = snapshot.data ?? [];
                return Column(
                  spacing: 5,
                  children: List.generate(
                    list.length,
                    (index) {
                      final url = list[index];
                      return ListTile(
                        textColor:
                            url == widget.controller.text ? Colors.teal : null,
                        onTap: () {
                          widget.controller.text = url;
                          widget.onChanged(url);
                          Navigator.pop(context);
                        },
                        title: Text(url),
                      );
                    },
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          child: TTextField(
            controller: widget.controller,
            label: Text('Forward Proxy'),
            onChanged: widget.onChanged,
          ),
        ),
        IconButton(
          onPressed: _onChooseOnline,
          icon: Icon(Icons.cloud_download_rounded),
        ),
      ],
    );
  }
}
