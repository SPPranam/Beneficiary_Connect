import 'package:flutter/material.dart';
import 'package:login_signup/screens/models/category.dart';
import 'package:login_signup/screens/models/meal.dart';
import 'package:url_launcher/url_launcher.dart';

const availableCategories = [
  Category(
    id: 'c1',
    title: 'LIC',
    color: Colors.purple,
  ),
  Category(
    id: 'c2',
    title: 'PLI',
    color: Colors.red,
  ),
  Category(
    id: 'c3',
    title: 'TATA',
    color: Colors.orange,
  ),
  Category(
    id: 'c4',
    title: 'Investment',
    color: Colors.amber,
  ),
  Category(
    id: 'c5',
    title: 'Vehicle',
    color: Colors.blue,
  ),
  Category(
    id: 'c6',
    title: 'RD',
    color: Colors.green,
  ),
  // Category(
  //   id: 'c7',
  //   title: '',
  //   color: Colors.lightBlue,
  // ),
  // Category(
  //   id: 'c8',
  //   title: '',
  //   color: Colors.lightGreen,
  // ),
  // Category(
  //   id: 'c9',
  //   title: '',
  //   color: Colors.pink,
  // ),
  // Category(
  //   id: 'c10',
  //   title: '',
  //   color: Colors.teal,
  // ),
];

const dummyMeals = [
  Meal(
    id: 'm1',
    categories: [
      'c1',
    ],
    title: "LIC's Jeevan Bharathi",
    affordability: Affordability.Basic,
    complexity: Complexity.Whole_Life,
    imageUrl:'https://i.pinimg.com/564x/cd/4a/a9/cd4aa9c7b91524ae829efdad39e8c2a8.jpg',
    duration: 1,
    ingredients: [
      "Contact +91-8976862090",
      " ",
      "Age and Key Roles: Age is calculated as the nearest birthday of the Life Assured at policy commencement, except for specific terms where minimum age is 5 years completed for 15-year terms and 90 days completed for 20 & 25-year terms.",
      " ",
      "Premiums and Policy Terms : Annualized Premium is the yearly premium amount excluding taxes, rider premiums, and extra charges.",
      " ",
      "Policy Status and Conditions: Terms like In-force policy, Lapse, Paid-Up, and Surrender are defined, detailing the status of premium payments and policy continuity.",
      " ",
      "Legal and Administrative Details: References to the Insurance Act, 1938, and IRDAI guidelines ensure legal compliance. ",
    ],
    steps: [
      //
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
   percentage: 0.0,
  ),
  Meal(
    id: 'm1',
    categories: [
      'c1',
    ],
    title: "LIC’s New Jeevan Mangal",
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:'https://i.pinimg.com/564x/cd/4a/a9/cd4aa9c7b91524ae829efdad39e8c2a8.jpg',
    duration: 1,
    ingredients : [
    "Contact: +91-8976862090",
    " ",
    "Age Calculation: Defines age as the nearest birthday of the Life Assured at the policy's commencement, except for age 0, which is 90 days completed.",
    "  ",
    "Roles: Includes definitions for appointees, assignees, beneficiaries, and nominees.",
    "  ",
    "Premiums: Clarifies types such as annualized, extra, and rider premiums.",
    "  ",
    "Benefits: Details death, maturity, and surrender benefits.",
    " ",
    "Legal and Regulatory References: Includes references to the Insurance Act, 1938, and IRDAI guidelines.",
  ],
    steps: [
      //
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",

    ],
   percentage: 0.0,
  ),
  Meal(
    id: 'm2',
    categories: [
      'c2',
    ],
    title: 'Postal Life Insurance',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://pli.indiapost.gov.in/CustomerPortal/images_mo/popcorn.png',
    duration: 1,
    ingredients: [
      "Contact 1800 180 5232/155232",
      " ",
      "Policy Bond and Premium Payments:Keep your policy bond safe as it is essential for servicing events, including claims. Inform your family where it is kept.",
      " ",
      "Premium Payment Methods:Premiums can be paid at any post office or through salary deductions. Regularly check your salary slip to ensure premiums are being deducted and remitted correctly, especially if transferred to a new office. ",
      " ",
      "Policy Lapsation and Reinstatement: Policies lapse if premiums are unpaid: for less than three-year policies, after six unpaid premiums; for more than three-year policies, after twelve unpaid premiums.",
      "Reinstatement is possible by paying arrears with interest and submitting a certificate of good health and employer certification if applicable.",
    ],
    steps: [
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
  Meal(
    id: 'm3',
    categories: [
      'c3',
    ],
    title: 'Tata AIG',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://main.quantafi.in/home/casestudy/uploads/1404211618386615_thump.jpg',
    duration: 1,
    ingredients : [
  "Contact +91-9136160375/1800-266-7780",
  " ",
  "Policy Bond and Premium Payments: Keep your policy bond safe as it is essential for servicing events, including claims. Inform your family where it is kept.",
  " ",
  "Premium Payment Methods: Premiums can be paid at any post office or through salary deductions. Regularly check your salary slip to ensure premiums are being deducted and remitted correctly, especially if transferred to a new office.",
  " ",
  "Policy Lapsation and Reinstatement: Policies lapse if premiums are unpaid: for less than three-year policies, after six unpaid premiums; for more than three-year policies, after twelve unpaid premiums.",
  "Reinstatement is possible by paying arrears with interest and submitting a certificate of good health and employer certification if applicable.",
],
    steps: [
    'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
   Meal(
    id: 'm3',
    categories: [
      'c4',
    ],
    title: 'FDP(Fixed Deposit PO)',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://media.istockphoto.com/id/691586724/photo/fixed-deposit.jpg?s=612x612&w=0&k=20&c=wgrD5fi-nv0OsV-G6ObP-fcZhv-b6G7TL29WABIn64Y=',
    duration: 1,
    ingredients: [
      "Contact 1800 266 6868",
      " ",
      "1yr.A/c : 6.9%",
      " ",
      "2yr.A/c : 7.0%",
      " ",
      "3yr.A/c : 7.1% ",
      " ",
      "5yr.A/c : 7.5%",
      " ",
      "Interest payable annually but calculated quarterly.",
    ],
    steps: [
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
  Meal(
    id: 'm3',
    categories: [
      'c4',
    ],
    title: 'FDB (Fixed Deposits Bank)',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://media.istockphoto.com/id/691586724/photo/fixed-deposit.jpg?s=612x612&w=0&k=20&c=wgrD5fi-nv0OsV-G6ObP-fcZhv-b6G7TL29WABIn64Y=',
    duration: 1,
    ingredients: [
      'General Citizen : 7.2%',
      ' ',
      'Senior Citizen : 7.75%',
      " ",
    ],
    steps: [
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
  Meal(
    id: 'm5',
    categories: [
          'c5',
    ],
    title: 'New India Assurance',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://i.pinimg.com/564x/1b/50/95/1b5095f09e9441645b0ffec9b8885476.jpg',
    duration: 1,
    ingredients: [
     'Coverage and Towing Charges:The policy covers towing charges up to INR 300 for scooters/motorcycles and INR 1,500 for cars and commercial vehicles from the accident site to the workshop. Higher towing charges can be opted for with extra premium payment.',
     ' ',
     'Policy Exclusions : The policy does not cover wear and tear, breakdowns, consequential loss, loss while driving with an invalid license or under the influence of alcohol, loss due to war, and claims from contractual liability. It also excludes use of the vehicle not in accordance with its intended use (e.g., using a private car as a taxi).',
     ' ',
     "Rating Factors and Add-on Covers: Premium rates depend on factors like Insured's Declared Value (IDV), cubic capacity, geographical zone, age of the vehicle, and Gross Vehicle Weight (GVW) for commercial vehicles.",
     " ",
     "Eligibility and Sum Insured:The sum insured, or IDV, is based on the vehicle's listed selling price adjusted for depreciation. For vehicles older than 5 years or obsolete models, the IDV is determined through mutual agreement between the insurer and the insured.",
     ' ',
    ],
    steps: [
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
  Meal(
    id: 'm6',
    categories: [
      'c6',
    ],
    title: 'Postal RD',
    affordability: Affordability.Basic,
    complexity: Complexity.hard,
    imageUrl:
        'https://i.pinimg.com/564x/04/b9/3b/04b93bbaf69b86eb88b72b11fd71d178.jpg',
    duration: 1,
    ingredients: [
      "Contact 1800 266 6868",
      " ",
      "Account Opening: Single adults, joint accounts (up to 3 adults), guardians on behalf of minors or persons of unsound mind, and minors above 10 years can open accounts.",
      " ",
      "Deposits:Minimum monthly deposit is Rs. 100, with subsequent deposits required by specific dates depending on the account opening date.",
      "Default charges apply if subsequent deposits are missed, with accounts becoming discontinued after 4 regular defaults.",
      '',
      "Closure and Maturity : Premature closure is allowed after 3 years, subject to certain conditions and applicable interest rates.",
      " ",
      ' Repayment on the death of the account holder can be claimed by the nominee or legal heirs, with options to continue the account till maturity.',
    ],
    steps: [
      'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
  Meal(
    id: 'm7',
    categories: [
      'c6',
    ],
    title: 'Bank RD',
    affordability: Affordability.Basic,
    complexity: Complexity.simple,
    imageUrl:
        'https://i.pinimg.com/564x/04/b9/3b/04b93bbaf69b86eb88b72b11fd71d178.jpg',
    duration: 1,
    ingredients: [
     'Minimum deposit: The minimum amount that can be deposited varies by bank, but can be as low as Rs. 100',
     " ",
     'Minimum deposit period: The minimum amount of time that deposits must be made for is usually six months, but can be as long as 10 years',
     ' ',
     "Lock-in period: RDs typically have a lock-in period of 30 days to 3 months",
     " ",
     "Interest rate: The interest rate is fixed when the account is opened and is usually higher than a regular savings account, but varies by bank",
     " ",
     "Premature withdrawals: Most banks allow early withdrawals, but they usually come with a penalty",
     " ",
     "Compound interest: Interest on RD accounts is often compounded quarterly, so account holders can receive a larger amount of interest and principal when the account matures",
    ],
    steps: [
     'Click On Purchase Button',
      " ",
      " Fill The Details Asked",
      "  ",
      " Click On Submit",
      " ",
      "Page Will Be Directed To Payment",
      "  ",
      "Pay Amount",
      
    ],
    percentage: 0.0
  ),
];