import 'package:flutter/material.dart';
class Desktop extends StatefulWidget {
	const Desktop({super.key});
	@override
		DesktopState createState() => DesktopState();
	}
class DesktopState extends State<Desktop> {
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
									decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(15),
										color: Color(0xFFFFFFFF),
									),
									width: double.infinity,
									height: double.infinity,
									child: SingleChildScrollView(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												IntrinsicHeight(
													child: Container(
														margin: const EdgeInsets.only( top: 11, bottom: 21, right: 1726),
														width: double.infinity,
														child: Stack(
															clipBehavior: Clip.none,
															children: [
																Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Container(
																			height: 184,
																			width: double.infinity,
																			child: Image.network(
																				"https://storage.googleapis.com/tagjs-prod.appspot.com/hQVmalDnMM/7h3y605m.png",
																				fit: BoxFit.fill,
																			)
																		),
																	]
																),
																Positioned(
																	top: 77,
																	right: 0,
																	width: 192,
																	height: 24,
																	child: Container(
																		transform: Matrix4.translationValues(142, 0, 0),
																		child: Text(
																			"Nombre persona",
																			style: TextStyle(
																				color: Color(0xFF000000),
																				fontSize: 24,
																				fontWeight: FontWeight.bold,
																			),
																		),
																	),
																),
															]
														),
													),
												),
												IntrinsicHeight(
													child: Container(
														decoration: BoxDecoration(
															borderRadius: BorderRadius.circular(26),
															color: Color(0xFF2600FF),
															boxShadow: [
																BoxShadow(
																	color: Color(0x40000000),
																	blurRadius: 4,
																	offset: Offset(12, 16),
																),
															],
														),
														padding: const EdgeInsets.only( top: 27, bottom: 565),
														margin: const EdgeInsets.only( right: 1519),
														width: double.infinity,
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Container(
																	margin: const EdgeInsets.only( bottom: 30, left: 15),
																	child: Text(
																		"Principal",
																		style: TextStyle(
																			color: Color(0xFFFFFFFF),
																			fontSize: 32,
																			fontWeight: FontWeight.bold,
																		),
																	),
																),
																IntrinsicHeight(
																	child: Container(
																		padding: const EdgeInsets.symmetric(vertical: 15),
																		margin: const EdgeInsets.only( bottom: 21, left: 13, right: 78),
																		width: double.infinity,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				Text(
																					"Mantenimiento",
																					style: TextStyle(
																						color: Color(0xFFFFFFFF),
																						fontSize: 32,
																						fontWeight: FontWeight.bold,
																					),
																				),
																			]
																		),
																	),
																),
																IntrinsicHeight(
																	child: Container(
																		padding: const EdgeInsets.symmetric(vertical: 15),
																		margin: const EdgeInsets.only( bottom: 21, left: 14, right: 78),
																		width: double.infinity,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				Text(
																					"Movimientos",
																					style: TextStyle(
																						color: Color(0xFFFFFFFF),
																						fontSize: 32,
																						fontWeight: FontWeight.bold,
																					),
																				),
																			]
																		),
																	),
																),
																IntrinsicHeight(
																	child: Container(
																		padding: const EdgeInsets.symmetric(vertical: 16),
																		margin: const EdgeInsets.only( left: 13, right: 78),
																		width: double.infinity,
																		child: Column(
																			crossAxisAlignment: CrossAxisAlignment.start,
																			children: [
																				Text(
																					"Reportes",
																					style: TextStyle(
																						color: Color(0xFFFFFFFF),
																						fontSize: 32,
																						fontWeight: FontWeight.bold,
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
						],
					),
				),
			),
		);
	}
}