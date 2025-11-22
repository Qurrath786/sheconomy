// lib/screens/learn/lessons_data.dart
import 'lesson_model.dart';

final List<Lesson> lessons = [
  Lesson(
    id: 'budgeting',
    title: 'Budgeting Basics',
    subtitle: 'Tap to open detailed lesson ',
    overview:
        'Learn how to create a simple, realistic monthly budget that matches your income and goals.',
    keyPoints: [
      'Track all income and expenses for one month.',
      'Differentiate between needs and wants.',
      'Allocate money for savings before spending.',
    ],
    steps: [
      'Write down monthly income (salary, side income).',
      'List fixed expenses and variable expenses.',
      'Set a target savings amount (e.g., 20% of income).',
      'Use envelopes or sub-accounts for spending categories.',
      'Review and adjust every month.',
    ],
    furtherReading: 'Create a 30-day expense log and review at month-end.',
  ),
  Lesson(
    id: 'saving',
    title: 'Saving Strategies',
    subtitle: 'Tap to open detailed lesson ',
    overview:
        'Practical saving approaches — from emergency funds to automated transfers and goal-based saving.',
    keyPoints: [
      'Aim for 3–6 months of emergency savings.',
      'Automate transfers to a savings account.',
      'Use goal-based buckets (travel, education, etc.).',
    ],
    steps: [
      'Open a separate savings account or sub-savings accounts.',
      'Automate a fixed transfer each salary day.',
      'Start a small target (e.g., ₹1,000/month) and increase gradually.',
    ],
    furtherReading:
        'Set a 6-month emergency fund goal and create monthly micro-goals to reach it.',
  ),
  Lesson(
    id: 'investing',
    title: 'Investing 101',
    subtitle: 'Tap to open detailed lesson ',
    overview:
        'Intro to long-term investing: understanding risk, diversification, and basic investment vehicles.',
    keyPoints: [
      'Start early and benefit from compounding.',
      'Diversify across assets (stocks, bonds, mutual funds).',
      'Match risk tolerance with investment horizon.',
    ],
    steps: [
      'Define your goal and time horizon.',
      'Learn difference: savings vs. investing vs. emergency funds.',
      'Start with low-cost index funds or SIPs in mutual funds.',
      'Rebalance portfolio annually and avoid frequent trading.',
    ],
    furtherReading:
        'If new to investing, open a small SIP and observe for 12 months.',
  ),
  Lesson(
    id: 'debt',
    title: 'Debt Management',
    subtitle: 'Tap to open detailed lesson ',
    overview:
        'How to handle high-interest debt, prioritise repayments, and avoid debt traps.',
    keyPoints: [
      'List all debts with interest rates and minimum payments.',
      'Prioritise high-interest debt (credit cards).',
      'Consider debt consolidation where appropriate.',
    ],
    steps: [
      'Make a debt inventory showing balances, rates, and due dates.',
      'Use the snowball or avalanche method.',
      'Negotiate lower interest rates or longer terms if possible.',
    ],
    furtherReading:
        'Create a debt-payoff timeline and increase payments from extra income.',
  ),
];
