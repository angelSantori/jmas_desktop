import 'package:flutter/material.dart';
class DashboardLogin extends StatefulWidget {
	const DashboardLogin({super.key});
	@override
		DashboardLoginState createState() => DashboardLoginState();
	}
class DashboardLoginState extends State<DashboardLogin> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SafeArea(
				child: Container(
					constraints: const BoxConstraints.expand(),
					color: Color(0xFFFFFFFF),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: Container(
									width: double.infinity,
									height: double.infinity,
									decoration: BoxDecoration(
										image: DecorationImage(
											image: NetworkImage("https://storage.googleapis.com/tagjs-prod.appspot.com/hQVmalDnMM/dvhohgrz.png"),
											fit: BoxFit.cover
										),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Expanded(
												child: Container(
													width: double.infinity,
													height: double.infinity,
													child: SingleChildScrollView(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																IntrinsicHeight(
																	child: Container(
																		width: 300,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				Container(
																					margin: const EdgeInsets.only( bottom: 72, left: 90, right: 90),
																					height: 97,
																					width: double.infinity,
																					child: Image.network(
																						"https://storage.googleapis.com/tagjs-prod.appspot.com/hQVmalDnMM/3lzzr4nk.png",
																						fit: BoxFit.fill,
																					)
																				),
																				IntrinsicHeight(
																					child: Container(
																						decoration: BoxDecoration(
																							border: Border.all(
																								color: Color(0xFFFFFFFF),
																								width: 1,
																							),
																							borderRadius: BorderRadius.circular(4),
																						),
																						padding: const EdgeInsets.only( top: 13, bottom: 13, left: 12, right: 166),
																						margin: const EdgeInsets.only( bottom: 20),
																						width: double.infinity,
																						child: Row(
																							children: [
																								Container(
																									width: 20,
																									height: 20,
																									child: Image.network(
																										"https://storage.googleapis.com/tagjs-prod.appspot.com/hQVmalDnMM/f1gmwoum.png",
																										fit: BoxFit.fill,
																									)
																								),
																								Expanded(
																									child: Container(
																										width: double.infinity,
																										child: SizedBox(),
																									),
																								),
																								Text(
																									"Username",
																									style: TextStyle(
																										color: Color(0xFFFFFFFF),
																										fontSize: 14,
																									),
																								),
																							]
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						decoration: BoxDecoration(
																							border: Border.all(
																								color: Color(0xFFFFFFFF),
																								width: 1,
																							),
																							borderRadius: BorderRadius.circular(4),
																						),
																						padding: const EdgeInsets.only( top: 13, bottom: 13, left: 12, right: 165),
																						margin: const EdgeInsets.only( bottom: 43),
																						width: double.infinity,
																						child: Row(
																							children: [
																								Container(
																									width: 20,
																									height: 20,
																									child: Image.network(
																										"https://storage.googleapis.com/tagjs-prod.appspot.com/hQVmalDnMM/kxcsggfc.png",
																										fit: BoxFit.fill,
																									)
																								),
																								Expanded(
																									child: Container(
																										width: double.infinity,
																										child: SizedBox(),
																									),
																								),
																								Text(
																									"password",
																									style: TextStyle(
																										color: Color(0xFFFFFFFF),
																										fontSize: 14,
																									),
																								),
																							]
																						),
																					),
																				),
																				InkWell(
																					onTap: () { print('Pressed'); },
																					child: IntrinsicHeight(
																						child: Container(
																							decoration: BoxDecoration(
																								borderRadius: BorderRadius.circular(4),
																								color: Color(0xFFFFFFFF),
																								boxShadow: [
																									BoxShadow(
																										color: Color(0x4D000000),
																										blurRadius: 4,
																										offset: Offset(0, 4),
																									),
																								],
																							),
																							padding: const EdgeInsets.symmetric(vertical: 17),
																							margin: const EdgeInsets.only( bottom: 15),
																							width: double.infinity,
																							child: Column(
																								children: [
																									Text(
																										"login",
																										style: TextStyle(
																											color: Color(0xFF2148C0),
																											fontSize: 16,
																											fontWeight: FontWeight.bold,
																										),
																									),
																								]
																							),
																						),
																					),
																				),
																				IntrinsicHeight(
																					child: Container(
																						width: double.infinity,
																						child: Column(
																							crossAxisAlignment: CrossAxisAlignment.end,
																							children: [
																								Container(
																									margin: const EdgeInsets.only( right: 3),
																									child: Text(
																										"Forgot password?",
																										style: TextStyle(
																											color: Color(0xFFFFFFFF),
																											fontSize: 16,
																											fontWeight: FontWeight.bold,
																										),
																									),
																								),
																							]
																						),
																					),
																				),
																			]
																		),
																	),
																),
															],
														)
													),
												),
											),
										]
									),
								),
							),
						],
					),
				),
			),
		);
	}
}