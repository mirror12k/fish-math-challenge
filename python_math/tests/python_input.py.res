[] => 
	type => assignment_statement
	identifier => a
	expression_list => 
		[] => 
			value => 123
			type => number_value
[] => 
	type => assignment_statement
	identifier => a
	expression_list => 
		[] => 
			value => 10
			type => number_value
[] => 
	type => if_statement
	expression => 
		type => binary_expression
		right_expression => 
			value => 5
			type => number_value
		operator => *
		line_number => 6
		left_expression => 
			type => binary_expression
			right_expression => 
				value => 2
				type => number_value
			operator => ==
			line_number => 6
			left_expression => 
				type => variable_value
				identifier => a
	branch => 
		[] => 
			type => elif_statement
			line_number => 6
			expression => 
				type => binary_expression
				right_expression => 
					value => 2
					type => number_value
				operator => *
				line_number => 8
				left_expression => 
					type => binary_expression
					right_expression => 
						value => 2
						type => number_value
					operator => ==
					line_number => 8
					left_expression => 
						type => variable_value
						identifier => a
			block => 
				[] => 
					type => expression_statement
					expression => 
						type => function_call_expression
						line_number => 9
						expression_list => 
							[] => 
								value => 4444
								type => number_value
						expression => 
							type => variable_value
							identifier => print
		[] => 
			type => elif_statement
			line_number => 6
			expression => 
				type => binary_expression
				right_expression => 
					value => 2
					type => number_value
				operator => ==
				line_number => 10
				left_expression => 
					type => variable_value
					identifier => a
			block => 
				[] => 
					type => expression_statement
					expression => 
						type => function_call_expression
						line_number => 11
						expression_list => 
							[] => 
								value => 2222
								type => number_value
						expression => 
							type => variable_value
							identifier => print
		[] => 
			type => else_statement
			line_number => 6
			block => 
				[] => 
					type => expression_statement
					expression => 
						type => function_call_expression
						line_number => 13
						expression_list => 
							[] => 
								value => 1111
								type => number_value
						expression => 
							type => variable_value
							identifier => print
				[] => 
					type => function_definition_statement
					identifier => fun
					block => 
						[] => 
							type => for_statement
							identifier => n
							expression => 
								type => function_call_expression
								line_number => 16
								expression_list => 
									[] => 
										type => variable_value
										identifier => a
								expression => 
									type => variable_value
									identifier => range
							block => 
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 17
										expression_list => 
											[] => 
												type => variable_value
												identifier => n
										expression => 
											type => variable_value
											identifier => print
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 20
										expression_list => 
											[] => 
												value => 5
												type => number_value
										expression => 
											type => variable_value
											identifier => fun
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 23
										expression_list => 
											[] => 
												type => variable_value
												identifier => a
										expression => 
											type => variable_value
											identifier => print
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 24
										expression_list => 
											[] => 
												type => variable_value
												identifier => a
											[] => 
												type => variable_value
												identifier => a
											[] => 
												type => variable_value
												identifier => a
										expression => 
											type => variable_value
											identifier => print
								[] => 
									type => assignment_statement
									identifier => l
									expression_list => 
										[] => 
											value => 
												[] => 
													value => 56
													type => number_value
												[] => 
													value => 78
													type => number_value
												[] => 
													value => 90
													type => number_value
											type => list_value
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 31
										expression_list => 
											[] => 
												value => 100
												type => number_value
										expression => 
											type => access_expression
											line_number => 31
											identifier => append
											expression => 
												type => variable_value
												identifier => l
								[] => 
									type => expression_statement
									expression => 
										type => function_call_expression
										line_number => 33
										expression_list => 
											[] => 
												type => variable_value
												identifier => l
											[] => 
												type => binary_expression
												right_expression => 
													value => 10.1
													type => number_value
												operator => /
												line_number => 33
												left_expression => 
													type => array_access_expression
													line_number => 33
													expression => 
														type => variable_value
														identifier => l
													access_expression => 
														value => 3
														type => number_value
										expression => 
											type => variable_value
											identifier => print
								[] => 
									type => import_statement
									identifier => math
								[] => 
									type => function_definition_statement
									identifier => compute
									block => 
										[] => 
											type => assignment_statement
											identifier => n
											expression_list => 
												[] => 
													value => 600851475143
													type => number_value
										[] => 
											type => whilee_statement
											expression => 
												value => True
												type => boolean_value
											block => 
												[] => 
													type => assignment_statement
													identifier => p
													expression_list => 
														[] => 
															type => function_call_expression
															line_number => 47
															expression_list => 
																[] => 
																	type => variable_value
																	identifier => n
															expression => 
																type => variable_value
																identifier => smallest_prime_factor
												[] => 
													type => if_statement
													expression => 
														type => binary_expression
														right_expression => 
															type => variable_value
															identifier => n
														operator => <
														line_number => 48
														left_expression => 
															type => variable_value
															identifier => p
													branch => 
														[] => 
															type => else_statement
															line_number => 48
															block => 
																[] => 
																	type => expression_statement
																	expression => 
																		type => variable_value
																		identifier => return
																[] => 
																	type => expression_statement
																	expression => 
																		type => variable_value
																		identifier => n
																[] => 
																	type => function_definition_statement
																	identifier => smallest_prime_factor
																	block => 
																		[] => 
																			type => for_statement
																			identifier => i
																			expression => 
																				type => function_call_expression
																				line_number => 56
																				expression_list => 
																					[] => 
																						value => 2
																						type => number_value
																					[] => 
																						type => binary_expression
																						right_expression => 
																							value => 1
																							type => number_value
																						operator => +
																						line_number => 56
																						left_expression => 
																							type => function_call_expression
																							line_number => 56
																							expression_list => 
																								[] => 
																									type => function_call_expression
																									line_number => 56
																									expression_list => 
																										[] => 
																											type => variable_value
																											identifier => n
																									expression => 
																										type => access_expression
																										line_number => 56
																										identifier => sqrt
																										expression => 
																											type => variable_value
																											identifier => math
																							expression => 
																								type => variable_value
																								identifier => int
																				expression => 
																					type => variable_value
																					identifier => range
																			block => 
																				[] => 
																					type => if_statement
																					expression => 
																						type => binary_expression
																						right_expression => 
																							value => 0
																							type => number_value
																						operator => ==
																						line_number => 57
																						left_expression => 
																							type => binary_expression
																							right_expression => 
																								type => variable_value
																								identifier => i
																							operator => %
																							line_number => 57
																							left_expression => 
																								type => variable_value
																								identifier => n
																					block => 
																						[] => 
																							type => expression_statement
																							expression => 
																								type => variable_value
																								identifier => return
																						[] => 
																							type => expression_statement
																							expression => 
																								type => variable_value
																								identifier => i
																						[] => 
																							type => expression_statement
																							expression => 
																								type => variable_value
																								identifier => return
																						[] => 
																							type => expression_statement
																							expression => 
																								type => variable_value
																								identifier => n
																						[] => 
																							type => expression_statement
																							expression => 
																								type => function_call_expression
																								line_number => 62
																								expression_list => 
																									[] => 
																										type => function_call_expression
																										line_number => 62
																										expression_list => 
																										expression => 
																											type => variable_value
																											identifier => compute
																								expression => 
																									type => variable_value
																									identifier => print
																	arguments => [] => n
													block => 
														[] => 
															type => expression_statement
															expression => 
																type => binary_expression
																right_expression => 
																	type => variable_value
																	identifier => p
																operator => //=
																line_number => 49
																left_expression => 
																	type => variable_value
																	identifier => n
									arguments => 
					arguments => [] => a
	block => 
		[] => 
			type => expression_statement
			expression => 
				type => function_call_expression
				line_number => 7
				expression_list => 
					[] => 
						value => 1337
						type => number_value
				expression => 
					type => variable_value
					identifier => print
good
