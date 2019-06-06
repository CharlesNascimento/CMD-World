package com.kansus.cmdwlfg;

import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;

import javax.imageio.ImageIO;

/**
 * Generate a level file for the CMD World game from a BMP image file.
 * 
 * @author Charles Nascimento
 */
public class LevelFileGenerator {

	private static HashMap<Integer, String> colorMappings = new HashMap<>();

	static {
		colorMappings.put(-1, " ");
		colorMappings.put(-256, "$");
		colorMappings.put(-16777216, "x");
		colorMappings.put(-65536, "p");
		colorMappings.put(-16711936, "d");
		colorMappings.put(-16776961, "k");
	}

	/**
	 * Main method.
	 * 
	 * @param args Arguments.
	 */
	public static void main(String[] args) {
		if (args.length == 0) {
			System.err.println("You must provide an input file");
			System.exit(-1);
		} else {
			if (!args[0].endsWith(".bmp")) {
				System.err.println("The input file must be a BMP image file.");
				System.exit(-1);
			}
		}

		try {
			File file = new File(args[0]);
			BufferedImage image = ImageIO.read(file);

			int[][] pixels = getPixels(image);
			
			String outputFile = args[0].replace("bmp", "map");
			saveLevelFile(pixels, outputFile);
		} catch (IOException ioe) {
			System.err.println(ioe.getMessage());
		}
	}

	/**
	 * Creates a two-dimensional array with pixel values of the input file.
	 * 
	 * @param image Input file.
	 * @return Two-dimensional array with pixel values.
	 */
	public static int[][] getPixels(BufferedImage image) {
		int width = image.getWidth();
		int height = image.getHeight();
		int[][] pixels = new int[width][height];

		for (int i = 0; i < width; i++) {
			for (int j = 0; j < height; j++) {
				pixels[i][j] = image.getRGB(i, j);
			}
		}

		return pixels;
	}

	/**
	 * Saves the final map file.
	 * 
	 * @param pixels Pixel values of the input image.
	 * @param fileName The map file name.
	 * @throws IOException
	 */
	public static void saveLevelFile(int[][] pixels, String fileName) throws IOException {
		File file = new File(fileName);
		file.createNewFile();

		FileWriter fileWriter = new FileWriter(file);
		BufferedWriter bw = new BufferedWriter(fileWriter);

		for (int i = 0; i < pixels[0].length; i++) {
			for (int j = 0; j < pixels.length; j++) {
				bw.write(colorMappings.get(pixels[j][i]));
			}

			// To avoid a new line at the end of the file
			if (i != pixels[0].length - 1) {
				bw.newLine();
			}
		}

		bw.close();
	}
}
