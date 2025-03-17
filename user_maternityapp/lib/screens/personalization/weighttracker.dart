import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:user_maternityapp/main.dart';
import 'package:user_maternityapp/screens/personalization/weight.dart';

class WeightTrackingPage extends StatefulWidget {
  const WeightTrackingPage({super.key});

  @override
  _WeightTrackingPageState createState() => _WeightTrackingPageState();
}

class _WeightTrackingPageState extends State<WeightTrackingPage> {
  List<Map<String, dynamic>> weightRecords = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Calculate stats
  double? currentWeight;
  double? previousWeight;
  double? weightChange;
  bool isWeightIncreased = false;

  Future<void> fetchWeightRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final response = await supabase
          .from('tbl_weighttracker')
          .select().eq('user_id', supabase.auth.currentUser!.id)
          .order('weighttracker_date', ascending: false);
      
      setState(() {
        weightRecords = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        
        // Calculate stats if we have records
        if (weightRecords.isNotEmpty) {
          currentWeight = weightRecords[0]['weighttracker_weight']?.toDouble();
          
          if (weightRecords.length > 1) {
            previousWeight = weightRecords[1]['weighttracker_weight']?.toDouble();
            if (currentWeight != null && previousWeight != null) {
              weightChange = currentWeight! - previousWeight!;
              isWeightIncreased = weightChange! > 0;
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Couldn't load weight records. Please try again.";
      });
      print("Error: $e");
    }
  }

  List<FlSpot> getChartData() {
    // Reverse the list to get chronological order for the chart
    final chronologicalRecords = List<Map<String, dynamic>>.from(weightRecords.reversed);
    List<FlSpot> spots = [];
    
    for (int i = 0; i < chronologicalRecords.length; i++) {
      final weight = chronologicalRecords[i]['weighttracker_weight']?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), weight));
    }
    
    return spots;
  }

  @override
  void initState() {
    super.initState();
    fetchWeightRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        title: Text(
          "Weight Tracker",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchWeightRecords,
          ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.blue[300]))
        : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(errorMessage!, style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: fetchWeightRecords,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Try Again"),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchWeightRecords,
              color: Colors.blue[300],
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildSummaryCard(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildChartCard(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        "WEIGHT HISTORY",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  weightRecords.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.scale_outlined, size: 64, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                "No weight records yet",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap the + button to add your first record",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final record = weightRecords[index];
                            final date = DateTime.parse(record['weighttracker_date']);
                            final weight = record['weighttracker_weight'];
                            
                            // Calculate if this weight is higher or lower than the previous one
                            bool? isHigher;
                            if (index < weightRecords.length - 1) {
                              final prevWeight = weightRecords[index + 1]['weighttracker_weight'];
                              isHigher = weight > prevWeight;
                            }
                            
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!, width: 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.monitor_weight,
                                        color: Colors.blue[400],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat('MMMM d, yyyy').format(date),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            DateFormat('EEEE, h:mm a').format(date),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "$weight kg",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        if (isHigher != null)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isHigher ? Icons.arrow_upward : Icons.arrow_downward,
                                                size: 14,
                                                color: isHigher ? Colors.red[400] : Colors.green[400],
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                isHigher ? "Increased" : "Decreased",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isHigher ? Colors.red[400] : Colors.green[400],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: weightRecords.length,
                        ),
                      ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WeightCheck()),
          );
          
          if (result == true) {
            fetchWeightRecords();
          }
        },
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        elevation: 2,
        icon: Icon(Icons.add),
        label: Text("Add Weight"),
        
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "CURRENT STATS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Weight",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentWeight != null ? "${currentWeight!.toStringAsFixed(1)} kg" : "No data",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
                if (weightChange != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isWeightIncreased ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isWeightIncreased ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                          color: isWeightIncreased ? Colors.red[400] : Colors.green[400],
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${weightChange!.abs().toStringAsFixed(1)} kg",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isWeightIncreased ? Colors.red[400] : Colors.green[400],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (weightRecords.isNotEmpty)
              Text(
                "Last updated: ${DateFormat('MMM d, yyyy').format(DateTime.parse(weightRecords[0]['weighttracker_date']))}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WEIGHT TREND",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
            weightRecords.length < 2
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    "Add more weight records to see your trend",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                )
              : Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              // Only show a few labels to avoid overcrowding
                              if (value.toInt() % 2 != 0 && value.toInt() != getChartData().length - 1) {
                                return SizedBox();
                              }
                              
                              if (value.toInt() >= weightRecords.length) {
                                return SizedBox();
                              }
                              
                              final index = weightRecords.length - 1 - value.toInt();
                              if (index < 0 || index >= weightRecords.length) {
                                return SizedBox();
                              }
                              
                              final date = DateTime.parse(weightRecords[index]['weighttracker_date']);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MMM d').format(date),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      minX: 0,
                      maxX: getChartData().length - 1.0,
                      minY: getChartData().map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 5,
                      maxY: getChartData().map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: getChartData(),
                          isCurved: true,
                          color: Colors.blue[300],
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue[400]!,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue[100]!.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
