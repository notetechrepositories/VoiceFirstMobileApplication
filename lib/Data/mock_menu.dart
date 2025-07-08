// import 'dart:convert';
// import 'package:voicefirst/Models/menu_item_model.dart';

// const String mockMenuJson = '''[
//   {
//     "id": 1,
//     "label": "Dashboard",
//     "icon": "dashboard",
//     "priority": "A",
//     "route": "/dashboard"
//   },
//   {
//     "id": 2,
//     "label": "Settings",
//     "icon": "settings",
//     "priority": "B",
//     "route": null,
//     "children": [
//       {
//         "id": 3,
//         "label": "User Management",
//         "icon": "users",
//         "priority": "BA",
//         "route": "/settings/users"
//       },
//       {
//         "id": 4,
//         "label": "Roles",
//         "icon": "lock",
//         "priority": "BB",
//         "route": "/settings/roles",
//         "children": [
//           {
//             "id": 5,
//             "label": "Audit Logs",
//             "icon": "file-search",
//             "priority": "BBA",
//             "route": "/settings/roles/audit"
//           }
//         ]
//       }
//     ]
//   },
//   {
//     "id": 6,
//     "label": "Reports",
//     "icon": "bar-chart",
//     "priority": "C",
//     "route": null,
//     "children": [
//       {
//         "id": 7,
//         "label": "Sales Report",
//         "icon": "line-chart",
//         "priority": "CA",
//         "route": "/reports/sales"
//       },
//       {
//         "id": 8,
//         "label": "User Report",
//         "icon": "users",
//         "priority": "CB",
//         "route": "/reports/users"
//       }
//     ]
//   },
//   {
//     "id": 9,
//     "label": "Projects",
//     "icon": "folder",
//     "priority": "D",
//     "route": null,
//     "children": [
//       {
//         "id": 10,
//         "label": "Ongoing",
//         "icon": "clock",
//         "priority": "DA",
//         "route": "/projects/ongoing"
//       },
//       {
//         "id": 11,
//         "label": "Completed",
//         "icon": "check-circle",
//         "priority": "DB",
//         "route": "/projects/completed"
//       },
//       {
//         "id": 12,
//         "label": "Archived",
//         "icon": "archive",
//         "priority": "DC",
//         "route": null,
//         "children": [
//           {
//             "id": 13,
//             "label": "By Year",
//             "icon": "calendar",
//             "priority": "DCA",
//             "route": "/projects/archived/year"
//           }
//         ]
//       }
//     ]
//   },
//   {
//     "id": 14,
//     "label": "Support",
//     "icon": "help-circle",
//     "priority": "E",
//     "route": null,
//     "children": [
//       {
//         "id": 15,
//         "label": "Tickets",
//         "icon": "mail",
//         "priority": "EA",
//         "route": "/support/tickets"
//       },
//       {
//         "id": 16,
//         "label": "Live Chat",
//         "icon": "message-circle",
//         "priority": "EB",
//         "route": "/support/chat"
//       },
//       {
//         "id": 17,
//         "label": "Knowledge Base",
//         "icon": "book-open",
//         "priority": "EC",
//         "route": null,
//         "children": [
//           {
//             "id": 18,
//             "label": "FAQ",
//             "icon": "help-circle",
//             "priority": "ECA",
//             "route": "/support/kb/faq"
//           },
//           {
//             "id": 19,
//             "label": "Guides",
//             "icon": "compass",
//             "priority": "ECB",
//             "route": "/support/kb/guides"
//           }
//         ]
//       }
//     ]
//   }
// ]
// ''';

// List<MenuItemModel> parseMenuItems() {
//   final List<dynamic> decoded = json.decode(mockMenuJson);
//   return decoded.map((e) => MenuItemModel.fromJson(e)).toList();
// }
