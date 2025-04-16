import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'constants.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FreightRatesApp());
}

class FreightRatesApp extends StatelessWidget {
  const FreightRatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freight Rates Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F3F7),
      ),
      home: const FreightRatesSearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FreightRatesSearchScreen extends StatefulWidget {
  const FreightRatesSearchScreen({super.key});

  @override
  State<FreightRatesSearchScreen> createState() =>
      _FreightRatesSearchScreenState();
}

class _FreightRatesSearchScreenState extends State<FreightRatesSearchScreen> {
  bool fcl = true;
  bool lcl = false;
  bool includeNearbyOriginPorts = false;
  bool includeNearbyDestinationPorts = false;
  String selectedContainerSize = '40\' Standard';
  DateTime? cutOffDate;
  String containerLength = '39.46ft';
  String containerWidth = '7.70 ft';
  String containerHeight = '7.84 ft';
  String selectedCommodity = 'General Cargo';
  final _formKey = GlobalKey<FormState>();

  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController boxesController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  List<String> originSuggestions = [];
  List<String> destinationSuggestions = [];
  bool isLoadingOrigin = false;
  bool isLoadingDestination = false;

  

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    boxesController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = constraints.maxWidth < 600;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and history button
                    buildHeader(),
                    const SizedBox(height: 20),

                    // Main form content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Origin and Destination fields
                            if (isPortrait) ...[
                              buildOriginField(),
                              const SizedBox(height: 16),
                              buildDestinationField(),
                            ] else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: buildOriginField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: buildDestinationField()),
                                ],
                              ),
                            const SizedBox(height: 20),

                            // Commodity and Cut Off Date fields
                            if (isPortrait) ...[
                              buildCommodityDropdown(),
                             
                              const SizedBox(height: 16),
                              buildCutOffDateField(),
                            ] else
                              Row(
                                children: [
                                  Expanded(child: buildCommodityDropdown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: buildCutOffDateField()),
                                ],
                              ),
                            const SizedBox(height: 20),

                            // Shipment Type
                            buildShipmentTypeSelection(),
                            const SizedBox(height: 20),

                            // Container Size, Boxes and Weight
                            if (isPortrait) ...[
                              buildCotainerSizeDropdown(),
                              const SizedBox(height: 16),
                              buildNumberOfBoxesField(),
                              const SizedBox(height: 16),
                              buildWeightField(),
                            ] else
                              Row(
                                children: [
                                  Expanded(child: buildCotainerSizeDropdown()),
                                  const SizedBox(width: 16),
                                  Expanded(child: buildNumberOfBoxesField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: buildWeightField()),
                                ],
                              ),
                            const SizedBox(height: 12),

                            // Information text
                            buildInfoText(),
                            const SizedBox(height: 20),

                            // Container Internal Dimensions
                            buildContainerDimensions(),

                            const SizedBox(height: 20),

                            // Search button
                            Center(child: buildSearchButton()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Search the best Freight Rates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('History'),
        ),
      ],
    );
  }

  Future<void> fetchSuggestions(String query, bool isOrigin) async {
    if (query.isEmpty) {
      setState(() {
        if (isOrigin) {
          originSuggestions = [];
          isLoadingOrigin = false;
        } else {
          destinationSuggestions = [];
          isLoadingDestination = false;
        }
      });
      return;
    }

    setState(() {
      if (isOrigin) {
        isLoadingOrigin = true;
      } else {
        isLoadingDestination = true;
      }
    });

    try {
      final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?name=$query'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<String> suggestions = data
            .map((university) => university['name'].toString())
            .toList()
            .cast<String>();

        setState(() {
          if (isOrigin) {
            originSuggestions = suggestions;
            isLoadingOrigin = false;
          } else {
            destinationSuggestions = suggestions;
            isLoadingDestination = false;
          }
        });
      } else {
        // Fallback mock data if API fails
       
            mockSuggestions.where((port) => port.toLowerCase().contains(query.toLowerCase()))
            .toList();

        setState(() {
          if (isOrigin) {
            originSuggestions = mockSuggestions;
            isLoadingOrigin = false;
          } else {
            destinationSuggestions = mockSuggestions;
            isLoadingDestination = false;
          }
        });
      }
    } catch (e) {
      // Fallback mock data if API fails
      
          mockSuggestions.where((port) => port.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        if (isOrigin) {
          originSuggestions = mockSuggestions;
          isLoadingOrigin = false;
        } else {
          destinationSuggestions = mockSuggestions;
          isLoadingDestination = false;
        }
      });
    }
  }

  Widget buildOriginField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return originSuggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            originController.text = selection;
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter origin location';
                }
                return null;
              },
              onChanged: (value) {
                fetchSuggestions(value, true);
              },
              decoration: InputDecoration(
                labelText: 'Origin',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: isLoadingOrigin
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            option,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: includeNearbyOriginPorts,
                onChanged: (value) {
                  setState(() {
                    includeNearbyOriginPorts = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Include nearby origin ports',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDestinationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return destinationSuggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            destinationController.text = selection;
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter destination location';
                }
                return null;
              },
              onChanged: (value) {
                fetchSuggestions(value, false);
              },
              decoration: InputDecoration(
                labelText: 'Destination',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: isLoadingDestination
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : null,
              ),
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            option,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: includeNearbyDestinationPorts,
                onChanged: (value) {
                  setState(() {
                    includeNearbyDestinationPorts = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Include nearby destination ports',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCommodityDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCommodity,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a commodity';
        }
        return null;
      },
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedCommodity = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Commodity',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: commodities.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget buildCotainerSizeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedContainerSize,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a Container Size';
        }
        return null;
      },
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedContainerSize = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'ConstainerSize',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: containerSizes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget buildCutOffDateField() {
    return TextField(
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            cutOffDate = picked;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Cut Off Date',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(
        text: cutOffDate != null
            ? DateFormat('MM/dd/yyyy').format(cutOffDate!)
            : '',
      ),
    );
  }

  Widget buildShipmentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipment Type :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildCheckboxWithLabel('FCL', fcl, (value) {
              setState(() {
                fcl = value ?? false;
              });
            }),
            const SizedBox(width: 24),
            buildCheckboxWithLabel('LCL', lcl, (value) {
              setState(() {
                lcl = value ?? false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget buildCheckboxWithLabel(
      String label, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget buildContainerSizeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedContainerSize,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            selectedContainerSize = newValue;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Container Size',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: ['40\' Standard'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget buildNumberOfBoxesField() {
    return TextFormField(
      controller: boxesController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter number of boxes';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'No of Boxes',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildWeightField() {
    return TextFormField(
      controller: weightController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter weight';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid weight';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Weight (Kg)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget buildInfoText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.info_outline, size: 18, color: Colors.grey),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'To obtain accurate rate for spot rate with guaranteed space and booking, please ensure your container count and weight per container is accurate.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Widget buildContainerDimensions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Container Internal Dimensions :',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  buildDimensionRow('Length', containerLength),
                  const SizedBox(height: 12),
                  buildDimensionRow('Width', containerWidth),
                  const SizedBox(height: 12),
                  buildDimensionRow('Height', containerHeight),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/container.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDimensionRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: () {
        if (_formKey.currentState?.validate() ?? false) {
          // Proceed with search
          // TODO: Implement search functionality
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      icon: const Icon(Icons.search),
      label: const Text('Search'),
    );
  }
}