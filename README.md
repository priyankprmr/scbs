# SCBS — Shivam Coolers Billing System

A simple billing and customer/order management app built for **Shivam Coolers**. It lets you create bills, manage customers and products, search by voice, export invoices to Excel, and print bills as PDF.

## Features

- **Customer management** — add, edit, search, and store customer details.
- **Product catalog** — maintain a list of coolers and related products with prices.
- **Billing** — create invoices by picking a customer and adding products, with optional discount and an auto-generated invoice number.
- **Voice input & search** — use speech-to-text for entering customer details and searching customers, products, and orders.
- **PDF bills** — generate a printable PDF invoice and send it to the system print dialog.
- **Excel export** — export the list of orders/invoices to an `.xlsx` file.
- **Offline storage** — all data is saved locally on the device, no internet required for core use.

## Tech / Services Used

- **Flutter** — app framework (Android).
- **Bloc** — state management.
- **Hive** (`hive_ce`) — local on-device data storage.
- **PDF** (`pdf` + `printing`) — bill generation and printing.
- **Excel** (`excel`) — exporting invoices to spreadsheet.
- **Speech-to-Text** (`speech_to_text`) — voice input and voice search.

## Getting Started

```bash
flutter pub get
flutter run
```
