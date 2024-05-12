# ECS502U LAB REPORT

This project documents the implementation of basic I/O interfacing using an 8051 microprocessor to control a Keypad/Display Unit. The main objective was to read input from a keypad and display the data on a seven-segment multiplexed display. The project also involves the use of an 8255 Programmable Peripheral Interface (PPI) to expand the I/O capabilities of the microprocessor.

## Overview

The project utilizes the following components and concepts:

- **Microprocessor:** 8051
- **Peripheral Interface:** 8255 (PPI)
- **I/O Expansion:** Utilization of 8255 to extend I/O lines from 12 to 24.
- **Display Control:** Multiplexing segments to display information on a 4-digit 7-segment display.
- **Keypad Input:** Detection of keypresses through row-column scanning using Port C.

## Key Components

- **Microprocessor:** 8051
- **Peripheral Interface:** 8255
- **I/O Expansion:** Utilized 8255 to extend I/O lines from 12 to 24.
- **Display Control:** Multiplexed segments using Port A and lower nibble of Port B.
- **Keypad Input:** Detected keypresses through row-column scanning using Port C.

## Achievements

- Successful integration of keypad input and display output using minimal I/O lines.
- Efficient utilization of microprocessor capabilities for real-time detection and display.

## Repository Structure

- **src:** Contains the source code for the project.
- **docs:** Documentation related to the project.

## Installation

To run the project, follow these steps:

1. Connect the hardware components as per the provided schematic.
2. Compile and upload the source code to the 8051 microprocessor.
3. Power on the system and test the keypad and display functionalities.

## Usage

Provide instructions for using the project. Include any necessary setup steps, usage guidelines, and examples.

## Contributing

If you'd like to contribute to the project, please follow these guidelines:

1. Fork the repository.
2. Make your changes.
3. Submit a pull request with a clear description of the changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
