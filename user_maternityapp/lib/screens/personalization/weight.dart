import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:user_maternityapp/main.dart';

class WeightCheck extends StatefulWidget {
  const WeightCheck({super.key});

  @override
  State<WeightCheck> createState() => _WeightCheckState();
}

class _WeightCheckState extends State<WeightCheck> {
  double weight = 55.0;
  DateTime selectedDate = DateTime.now();
  bool isSubmitting = false;
  String? errorMessage;
  
  // Weight input controller for manual entry
  final TextEditingController weightController = TextEditingController(text: "55.0");
  
  @override
  void initState() {
    super.initState();
    weightController.text = weight.toStringAsFixed(1);
  }
  
  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> saveWeight() async {
    if (weight <= 0) {
      setState(() {
        errorMessage = "Please enter a valid weight";
      });
      return;
    }
    
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });
    
    try {
      await supabase.from('tbl_weighttracker').insert({
        'weighttracker_weight': weight,
        'weighttracker_date': selectedDate.toIso8601String(),
      });
      
      // Return true to indicate successful submission
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isSubmitting = false;
        errorMessage = "Failed to save weight. Please try again.";
      });
      print("Error: $e");
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[400]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  
  void updateWeightFromTextField() {
    final enteredWeight = double.tryParse(weightController.text);
    if (enteredWeight != null && enteredWeight > 0 && enteredWeight <= 200) {
      setState(() {
        weight = enteredWeight;
        errorMessage = null;
      });
    } else {
      setState(() {
        errorMessage = "Please enter a valid weight between 1-200 kg";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        title: Text(
          "Record Weight",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Track Your Pregnancy Weight",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Regular weight tracking helps monitor your health and your baby's development during pregnancy.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                
                // Date selector
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.blue[400],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Weight gauge
                Container(
                  height: 250,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 120,
                        startAngle: 150,
                        endAngle: 30,
                        showLabels: true,
                        showTicks: true,
                        interval: 20,
                        axisLineStyle: AxisLineStyle(
                          thickness: 10,
                          color: Colors.grey[200],
                          thicknessUnit: GaugeSizeUnit.logicalPixel,
                        ),
                        majorTickStyle: MajorTickStyle(
                          length: 10,
                          thickness: 1.5,
                          color: Colors.grey[400],
                        ),
                        minorTickStyle: MinorTickStyle(
                          length: 5,
                          thickness: 1,
                          color: Colors.grey[300],
                        ),
                        minorTicksPerInterval: 4,
                        labelFormat: '{value}',
                        axisLabelStyle: GaugeTextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        ranges: <GaugeRange>[
                          GaugeRange(
                            startValue: 0,
                            endValue: 40,
                            color: Colors.blue[100],
                            startWidth: 10,
                            endWidth: 10,
                          ),
                          GaugeRange(
                            startValue: 40,
                            endValue: 90,
                            color: Colors.green[300],
                            startWidth: 10,
                            endWidth: 10,
                          ),
                          GaugeRange(
                            startValue: 90,
                            endValue: 120,
                            color: Colors.orange[300],
                            startWidth: 10,
                            endWidth: 10,
                          ),
                        ],
                        pointers: <GaugePointer>[
                          MarkerPointer(
                            value: weight,
                            markerType: MarkerType.circle,
                            color: Colors.pink[400],
                            markerHeight: 20,
                            markerWidth: 20,
                            enableDragging: true,
                            onValueChanged: (value) {
                              setState(() {
                                weight = double.parse(value.toStringAsFixed(1));
                                weightController.text = weight.toStringAsFixed(1);
                                errorMessage = null;
                              });
                            },
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "${weight.toStringAsFixed(1)} kg",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.8,
                          )
                        ],
                      )
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Manual weight entry
                Text(
                  "Or enter weight manually:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "Enter weight",
                          suffixText: "kg",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[400]!),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          // Clear error message when user starts typing
                          if (errorMessage != null) {
                            setState(() {
                              errorMessage = null;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: updateWeightFromTextField,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[700],
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Update"),
                    ),
                  ],
                ),
                
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                
                SizedBox(height: 40),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : saveWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Saving..."),
                          ],
                        )
                      : Text(
                          "SAVE WEIGHT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Health tips
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Healthy Weight Tips",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "During pregnancy, aim for a gradual weight gain of 1-2 kg per month. Consult with your healthcare provider about your specific weight gain goals.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

