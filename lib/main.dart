import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

// Models for JSON data
class BannerModel {
  final String title;
  final String description;

  BannerModel({required this.title, required this.description});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'],
      description: json['description'],
    );
  }
}

class CategoryModel {
  final String title;
  final String icon;

  CategoryModel({required this.title, required this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'],
      icon: json['icon'],
    );
  }
}

class NearbyCenterModel {
  final String title;
  final String locationName;

  NearbyCenterModel({
    required this.title,
    required this.locationName,
  });

  factory NearbyCenterModel.fromJson(Map<String, dynamic> json) {
    return NearbyCenterModel(
      title: json['title'],
      locationName: json['location_name'],
    );
  }
}

class DoctorModel {
  final String fullName;
  final String typeOfDoctor;

  DoctorModel({
    required this.fullName,
    required this.typeOfDoctor,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      fullName: json['full_name'],
      typeOfDoctor: json['type_of_doctor'],
    );
  }
}

// Controller for managing data
class DataController extends GetxController {
  var banners = <BannerModel>[].obs;
  var categories = <CategoryModel>[].obs;
  var nearbyCenters = <NearbyCenterModel>[].obs;
  var doctors = <DoctorModel>[].obs;

  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/v1.json');
      final data = json.decode(response);

      banners.value = List<BannerModel>.from(data['banners'].map((x) => BannerModel.fromJson(x)));
      categories.value = List<CategoryModel>.from(data['categories'].map((x) => CategoryModel.fromJson(x)));
      nearbyCenters.value = List<NearbyCenterModel>.from(data['nearby_centers'].map((x) => NearbyCenterModel.fromJson(x)));
      doctors.value = List<DoctorModel>.from(data['doctors'].map((x) => DoctorModel.fromJson(x)));
    } catch (error) {
      print('Error loading data: $error');
    }
  }
}

// Main widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Data from JSON',
      home: HomePage(),
    );
  }
}

// Home page widget
class HomePage extends StatelessWidget {
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data from JSON'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) => dataController.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banners
            Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dataController.banners.length,
              itemBuilder: (context, index) {
                final banner = dataController.banners[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(banner.title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(banner.description),
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey, // Gray square
                    ),
                  ),
                );
              },
            )),

            // Categories (Specialties)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Text('Specialties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Obx(() => Container(
              height: 100, // Set a fixed height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataController.categories.length,
                itemBuilder: (context, index) {
                  final category = dataController.categories[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey, // Gray square
                          child: Icon(Icons.local_hospital, color: Colors.white), // Example icon
                        ),
                        SizedBox(height: 8),
                        Text(category.title),
                      ],
                    ),
                  );
                },
              ),
            )),

            // Nearby Medical Centers
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: Text('Nearby Medical Centers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Obx(() => Container(
              height: 100, // Set a fixed height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataController.nearbyCenters.length,
                itemBuilder: (context, index) {
                  final center = dataController.nearbyCenters[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey, // Gray square
                        ),
                        SizedBox(height: 8),
                        Text(center.title),
                        SizedBox(height: 4),
                        Text(center.locationName, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            )),

            // Button to view all doctors
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the doctors list page
                  Get.to(() => DoctorsPage(doctors: dataController.doctors));
                },
                child: Text('View All Doctors'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Doctors Page
class DoctorsPage extends StatelessWidget {
  final List<DoctorModel> doctors;

  DoctorsPage({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctors')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(doctor.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(doctor.typeOfDoctor),
              leading: Container(
                width: 50,
                height: 50,
                color: Colors.grey, // Gray square
              ),
            ),
          );
        },
      ),
    );
  }
}
