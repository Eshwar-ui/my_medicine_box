// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_medicine_box/presentation/components/calender.dart';
import 'package:my_medicine_box/presentation/components/data_table.dart';

class Dashbord extends StatefulWidget {
  const Dashbord({super.key});

  @override
  State<Dashbord> createState() => _DashbordState();
}

class _DashbordState extends State<Dashbord> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            stretch: true,
            backgroundColor: Colors.transparent,
            expandedHeight: 250.h,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                top: true,
                bottom: false,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 10.0.sp, left: 5.0.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "My Medicine box",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.notifications_none,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      TextField(
                        showCursor: false,
                        cursorColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 29.sp),
                          fillColor: Theme.of(context).colorScheme.primary,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search, size: 25),
                          hintText: "search my meds...",
                          suffixIcon: Icon(Icons.mic_none_rounded),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: 135.h,
                          width: 110.w,
                          child: Image.asset(
                            fit: BoxFit.cover,
                            'lib/presentation/assets/images/bg_image.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(50),
                    topEnd: Radius.circular(50),
                  ),
                ),
              ),
              height: 700.h,
              child: Column(
                children: [
                  // Calendar widget
                  // Mycalender(),

                  // Meds title with edit icon
                  Padding(
                    padding: EdgeInsets.only(
                        left: 35.0.sp, right: 35.0.sp, top: 30.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "My Meds",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.download,
                                  size: 25,
                                )),
                            SizedBox(width: 20.sp),
                            Icon(Icons.edit, size: 25),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.sp),

                  // Table widget constrained by Flexible
                  Expanded(
                    child: MyTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
