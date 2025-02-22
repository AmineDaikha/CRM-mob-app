import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dropdown with Search'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearchWidget(),
          ),
        ),
      ),
    );
  }
}

class DropdownSearchWidget extends StatefulWidget {
  @override
  _DropdownSearchWidgetState createState() => _DropdownSearchWidgetState();
}

class _DropdownSearchWidgetState extends State<DropdownSearchWidget> {
  TextEditingController _searchController = TextEditingController();
  String _selectedValue = '';
  List<String> _items = ['admin', 'user', 'guest'];
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _items;
    _searchController.addListener(_filterItems);
  }

  void _filterItems() {
    setState(() {
      _filteredItems = _items
          .where((item) =>
          item.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filteredItems = _items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('grgrgrrgr'),),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: _clearSearch,
                        ),
                      DropdownButton<String>(
                        value: _selectedValue.isEmpty ? null : _selectedValue,
                        icon: Icon(Icons.arrow_drop_down),
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedValue = newValue!;
                          });
                        },
                        items: _filteredItems.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (_filteredItems.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredItems[index]),
                        onTap: () {
                          setState(() {
                            _selectedValue = _filteredItems[index];
                            _searchController.clear();
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
