# Codage CANAL (Matlab) -- ENSEEIHT 1SN Signal Processing Course

This project focuses on the study and implementation of **Channel Coding** (Codage Canal) to evaluate its impact on the spectral and power efficiency of a transmission chain. It simulates a baseband equivalent transmission using Binary Phase-Shift Keying (BPSK) over a Gaussian channel.

The project explores two main error-correction coding techniques:
1. **Linear Block Coding**: Implementation of the *Hamming Code* evaluating blocks of bits.
2. **Convolutional Coding**: Implementation using shift registers, creating continuous parity bits decoded via the *Viterbi Algorithm*.

Both methods are tested using both **Hard Decoding** (using Hamming distance) and **Soft Decoding** (using Euclidean distance on unquantized/analog symbols).

## Features

- **No Coding Transmission (BPSK):** Baseline comparison for Bit Error Rate (BER / TEB).
- **Hamming Code Simulation:** Encodes 4-bit information blocks into 7-bit codewords.
- **Convolutional Code Simulation:** 1/2 rate encoder with constraint length K=3.
- **Viterbi Decoding:** Included hard-decision and soft-decision variations.
- **Image Transmission Test:** Demonstrates reshaping and transmitting an image file as a bitstream.

## Requirements

- **MATLAB**
- **Communications Toolbox** (Required for functions like `poly2trellis`, `convenc`, `vitdec`, `de2bi`, etc.)

## How to Use

The repository contains several independent MATLAB scripts. You can run them directly in the MATLAB environment:

1. **`Codage_canal.m`**: Run this script to simulate the transmission chain using **Linear Block Coding (Hamming code)**. It loops over various $E_b/N_0$ levels, calculates the empirical Bit Error Rates (with and without coding, hard and soft decoding), and plots the comparative results.
   
2. **`Codage_canal_convolutif.m`**: Run this script to simulate the transmission chain using **Convolutional Coding**. Similar to the block coding script, it evaluates BER for various Signal-to-Noise Ratios and outputs comparative plots showcasing the efficiency of Viterbi soft and hard decoding scenarios.

3. **`Manipulation_image.m`**: A small utility script. It demonstrates how to read an image (e.g., `dcode-image.png`), flat-pack it into a binary stream simulating payload generation for the transmission chain, and reconstruct the image back from a binary array. 

## Project Report

For a detailed theoretical background, mathematical models, trellis diagrams, and comprehensive observations of the BER performance curves, please refer to the main report: [`rapport-demesy_rabefaniraka.pdf`](rapport-demesy_rabefaniraka.md).
