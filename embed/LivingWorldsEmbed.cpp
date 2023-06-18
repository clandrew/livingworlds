#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <vector>
#include <iomanip>

struct PaletteColor
{
	int R, G, B;
};

std::vector<int> MakeHalfsize(std::vector<int> indexedBuffer, int imageWidth, int imageHeight)
{
	// Assumption: this is a 1byte per pixel image.
	std::vector<int> result;

	for (int i = 0; i < indexedBuffer.size(); ++i)
	{
		int x = i % imageWidth;
		int y = i / imageWidth;

		if (x % 2 == 1)
			continue;

		if (y % 2 == 1)
			continue;

		result.push_back(indexedBuffer[i]);
	}
	return result;
}

int main()
{
	std::wstring destPaletteFilename = L"D:\\repos\\wormhole\\tinyvicky\\rsrc\\colors.s";
	std::wstring destImageFilename = L"D:\\repos\\wormhole\\tinyvicky\\rsrc\\pixmap.s";
	bool emitCompileOffsets = false;
	bool halfsize = true;

	std::ifstream input("scene(8).php");

	std::string line;
	std::getline(input, line);

	size_t index = 0;

	std::string prefix = "colors:[";
	size_t colorsIndex = line.find(prefix);
	index = colorsIndex;
	index += prefix.length();

	std::vector<PaletteColor> colors;
	std::vector<int> pixelData;

	for (int i = 0; i < 256; ++i)
	{
		PaletteColor color;

		{
			index++; // [
			size_t rIndex = line.find(",", index);
			std::istringstream ss(line.substr(index, rIndex - index));
			ss >> color.R;
			index = rIndex;
		}
		{
			index++; // ,
			size_t rIndex = line.find(",", index);
			std::istringstream ss(line.substr(index, rIndex - index));
			ss >> color.G;
			index = rIndex;
		}
		{
			index++; // ,
			size_t rIndex = line.find("]", index);
			std::istringstream ss(line.substr(index, rIndex - index));
			ss >> color.B;
			index = rIndex;
		}
		index++; // ]
		if (i < 256 - 1)
		{
			index++; // ,
		}
		colors.push_back(color);
	}

	// Now read the pixel data
	for (int y = 0; y < 480; ++y)
	{
		std::getline(input, line);
		index = 0;
		for (int x = 0; x < 640; ++x)
		{
			if (x > 0 || y > 0)
			{
				index++;
			}

			size_t rIndex = line.find(",", index);
			std::istringstream ss(line.substr(index, rIndex - index));
			int pixel = 0;
			ss >> pixel;
			pixelData.push_back(pixel);
			index = rIndex;
		}
	}
	{
		// Dump the palette
		std::wstring outputFile = destPaletteFilename;
		std::ofstream out(outputFile);
		out << "LUT_START\n";
		int colorIndex = 0;
		for (auto it = colors.begin(); it != colors.end() && colorIndex < 256; ++it)
		{
			out << ".byte $"
				<< std::setfill('0') << std::setw(2) << std::hex << it->B << ", $"
				<< std::setfill('0') << std::setw(2) << std::hex << it->G << ", $"
				<< std::setfill('0') << std::setw(2) << std::hex << it->R << ", $00\n";

			++colorIndex;
		}
		int fillerColors = 256 - colors.size();
		for (int i = 0; i < fillerColors; ++i)
		{
			out << ".byte $FF, $00, $FF, 0\n";
		}

		out << "\n";
		out << "LUT_END = *";
	}
	if (halfsize)
	{
		pixelData = MakeHalfsize(pixelData, 640, 480);
	}
	{
		// Dump the image data
		std::wstring outputFile = destImageFilename;
		std::ofstream out(outputFile);

		out << "\n";

		int bank = 2;
		const int lineLength = 16; // Emit 16 bytes per line
		int lineCount = 0;
		for (int i = 0; i < pixelData.size(); i += lineLength)
		{
			if (emitCompileOffsets)
			{
				if (lineCount % 4096 == 0)
				{
					out << "* = $";
					if (lineCount == 0)
					{
						out << "0";
					}
					out << bank << "0000\n";
					bank++;
				}
			}
			if (lineCount == 0)
			{
				out << "IMG_START = *\n";
			}

			int counter = 0;

			{
				out << ".byte ";
				bool firstInLine = true;

				for (int j = 0; j < lineLength; ++j)
				{
					int datum = pixelData[i + j];
					if (!firstInLine)
					{
						out << ", ";
					}
					out << "$" << std::setfill('0') << std::setw(2) << std::hex << datum;
					firstInLine = false;
					counter++;
				}
				out << "\n";
			}

			lineCount++;
		}

		out << "IMG_END = *";
	}

	int i = 5;
}
