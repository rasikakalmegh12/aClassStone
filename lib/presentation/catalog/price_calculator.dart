import 'package:flutter/material.dart';

class PriceCalculationResult {
  final String productId;
  final String grade;
  final String measurementType; // Inch or Trader
  final String unit; // sqft / piece / ton
  final double pricePerUnit;
  final double quantity;
  final double weight;
  final double transportCharge;
  final double tax; // absolute amount
  final double taxPercent; // if used percent
  final double misc;
  final double total;

  PriceCalculationResult({
    required this.productId,
    required this.grade,
    required this.measurementType,
    required this.unit,
    required this.pricePerUnit,
    required this.quantity,
    required this.weight,
    required this.transportCharge,
    required this.tax,
    required this.taxPercent,
    required this.misc,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'grade': grade,
        'measurementType': measurementType,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'quantity': quantity,
        'weight': weight,
        'transportCharge': transportCharge,
        'tax': tax,
        'taxPercent': taxPercent,
        'misc': misc,
        'total': total,
      };
}

class PriceCalculator extends StatefulWidget {
  final String productId;
  final Map<String, double> gradePrices; // e.g. {'A':250}

  const PriceCalculator({super.key, required this.productId, required this.gradePrices});

  @override
  State<PriceCalculator> createState() => _PriceCalculatorState();
}

class _PriceCalculatorState extends State<PriceCalculator> {
  final _formKey = GlobalKey<FormState>();
  String _measurementType = 'Inch';
  String _grade = 'A';
  String _unit = 'sqft';

  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _weightController;
  late TextEditingController _transportController;
  late TextEditingController _taxController;
  late TextEditingController _miscController;

  bool _taxIsPercent = true;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    final defaultPrice = widget.gradePrices[_grade] ?? 0.0;
    _priceController = TextEditingController(text: defaultPrice.toString());
    _quantityController = TextEditingController(text: '0');
    _weightController = TextEditingController(text: '0');
    _transportController = TextEditingController(text: '0');
    _taxController = TextEditingController(text: '0');
    _miscController = TextEditingController(text: '0');
    _recalculate();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _weightController.dispose();
    _transportController.dispose();
    _taxController.dispose();
    _miscController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final pricePerUnit = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final transport = double.tryParse(_transportController.text) ?? 0.0;
    final taxInput = double.tryParse(_taxController.text) ?? 0.0;
    final misc = double.tryParse(_miscController.text) ?? 0.0;

    double subtotal = 0.0;
    if (_unit == 'sqft' || _unit == 'piece') {
      subtotal = pricePerUnit * quantity;
    } else if (_unit == 'ton') {
      subtotal = pricePerUnit * weight;
    }

    double taxAmount = 0.0;
    if (_taxIsPercent) {
      taxAmount = subtotal * (taxInput / 100);
    } else {
      taxAmount = taxInput;
    }

    final total = subtotal + transport + taxAmount + misc;

    setState(() {
      _total = total;
    });
  }

  void _onGradeChanged(String? g) {
    if (g == null) return;
    setState(() {
      _grade = g;
      final p = widget.gradePrices[_grade] ?? 0.0;
      _priceController.text = p.toString();
    });
    _recalculate();
  }

  void _saveAndReturn() {
    final pricePerUnit = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final transport = double.tryParse(_transportController.text) ?? 0.0;
    final taxInput = double.tryParse(_taxController.text) ?? 0.0;
    final misc = double.tryParse(_miscController.text) ?? 0.0;

    final result = PriceCalculationResult(
      productId: widget.productId,
      grade: _grade,
      measurementType: _measurementType,
      unit: _unit,
      pricePerUnit: pricePerUnit,
      quantity: quantity,
      weight: weight,
      transportCharge: transport,
      tax: _taxIsPercent ? 0.0 : taxInput,
      taxPercent: _taxIsPercent ? taxInput : 0.0,
      misc: misc,
      total: _total,
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Price Calculator'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Measurement Type
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _measurementType,
                      items: const [DropdownMenuItem(value: 'Inch', child: Text('Inch Measurement')), DropdownMenuItem(value: 'Trader', child: Text('Trader Measurement'))],
                      onChanged: (v) => setState(() { _measurementType = v ?? 'Inch'; }),
                      decoration: const InputDecoration(labelText: 'Measurement Type'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _grade,
                      items: ['A','B','C','D'].map((g) => DropdownMenuItem(value: g, child: Text('Grade $g'))).toList(),
                      onChanged: _onGradeChanged,
                      decoration: const InputDecoration(labelText: 'Grade'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Unit & Price
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      items: const [DropdownMenuItem(value: 'sqft', child: Text('sqft')), DropdownMenuItem(value: 'piece', child: Text('piece')), DropdownMenuItem(value: 'ton', child: Text('ton'))],
                      onChanged: (v) => setState(() { _unit = v ?? 'sqft'; _recalculate(); }),
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price per unit'),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Quantity / Weight inputs
              if (_unit == 'ton') ...[
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (tons)'),
                  onChanged: (_) => _recalculate(),
                ),
              ] else ...[
                TextFormField(
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  onChanged: (_) => _recalculate(),
                ),
              ],

              const SizedBox(height: 12),

              // Transport, tax, misc
              TextFormField(
                controller: _transportController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Transport charges'),
                onChanged: (_) => _recalculate(),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: _taxController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: _taxIsPercent ? 'Tax (%)' : 'Tax (absolute)'),
                    onChanged: (_) => _recalculate(),
                  )),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const Text('Percent'),
                      Switch(value: _taxIsPercent, onChanged: (v) { setState(() => _taxIsPercent = v); _recalculate(); }),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _miscController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Other charges'),
                onChanged: (_) => _recalculate(),
              ),

              const SizedBox(height: 16),

              // Breakdown
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subtotal: ₹${_computeSubtotal().toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text('Transport: ₹${(double.tryParse(_transportController.text) ?? 0).toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text('Tax: ₹${_computeTaxAmount().toStringAsFixed(2)}'),
                      const SizedBox(height: 4),
                      Text('Other: ₹${(double.tryParse(_miscController.text) ?? 0).toStringAsFixed(2)}'),
                      const Divider(),
                      Text('Total: ₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveAndReturn(),
                      child: const Text('Save as Quote / Create Lead'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _priceController.text = (widget.gradePrices['A'] ?? 0.0).toString();
                        _quantityController.text = '0';
                        _weightController.text = '0';
                        _transportController.text = '0';
                        _taxController.text = '0';
                        _miscController.text = '0';
                        _recalculate();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _computeSubtotal() {
    final pricePerUnit = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    if (_unit == 'ton') return pricePerUnit * weight;
    return pricePerUnit * quantity;
  }

  double _computeTaxAmount() {
    final taxInput = double.tryParse(_taxController.text) ?? 0.0;
    final subtotal = _computeSubtotal();
    if (_taxIsPercent) return subtotal * (taxInput / 100);
    return taxInput;
  }
}
