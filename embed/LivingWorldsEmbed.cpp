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

struct Cycle
{
	int Low;
	int High;
	int Rate;
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

void WriteEmbedding(int sceneIndex)
{
	std::wstring directory = L"D:\\repos\\livingworlds\\fnx\\";

	std::wstring destPaletteFilename;
	{
		std::wstringstream ss;
		ss << directory << "rsrc\\colors." << sceneIndex << ".s";
		destPaletteFilename = ss.str();
	}
	std::wstring destImageFilename;
	{
		std::wstringstream ss;
		ss << directory << "rsrc\\pixmap." << sceneIndex << ".s";
		destImageFilename = ss.str();
	}
	std::wstring destCodeFilename;
	{
		std::wstringstream ss;
		ss << directory << "cycle." << sceneIndex << ".s";
		destCodeFilename = ss.str();
	}
	std::wstring inputFilename;
	{
		std::wstringstream ss;
		ss << L"scene(" << sceneIndex << ").php";
		inputFilename = ss.str();
	}

	bool emitCompileOffsets = false;
	bool halfsize = true;

	std::ifstream input(inputFilename);

	std::string firstline;
	std::getline(input, firstline);

	size_t index = 0;

	std::string prefix = "colors:[";
	size_t colorsIndex = firstline.find(prefix);
	index = colorsIndex;
	index += prefix.length();

	std::vector<PaletteColor> colors;
	std::vector<int> pixelData;
	std::vector<Cycle> cycles;

	for (int i = 0; i < 256; ++i)
	{
		PaletteColor color;

		{
			index++; // [
			size_t rIndex = firstline.find(",", index);
			std::istringstream ss(firstline.substr(index, rIndex - index));
			ss >> color.R;
			index = rIndex;
		}
		{
			index++; // ,
			size_t rIndex = firstline.find(",", index);
			std::istringstream ss(firstline.substr(index, rIndex - index));
			ss >> color.G;
			index = rIndex;
		}
		{
			index++; // ,
			size_t rIndex = firstline.find("]", index);
			std::istringstream ss(firstline.substr(index, rIndex - index));
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
		std::string line;
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
		out << "LUT_START" << sceneIndex << "\n";
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
		out << "LUT_END" << sceneIndex << " = *";
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
				out << "IMG_START" << sceneIndex << " = *\n";
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

		out << "IMG_END" << sceneIndex << " = *";
	}

	{
		index = 0;

		std::string prefix = "cycles:[";
		index = firstline.find(prefix);
		index += prefix.length();

		while (1)
		{
			Cycle cycle;

			{
				std::string prefix = "rate:";
				index = firstline.find(prefix, index);
				index += prefix.length();
				size_t rIndex = firstline.find(',', index);
				std::istringstream ss(firstline.substr(index, rIndex - index));
				ss >> cycle.Rate;
				index = rIndex;
			}
			{
				std::string prefix = "low:";
				index = firstline.find(prefix, index);
				index += prefix.length();
				size_t rIndex = firstline.find(',', index);
				std::istringstream ss(firstline.substr(index, rIndex - index));
				ss >> cycle.Low;
				index = rIndex;
			}
			{
				std::string prefix = "high:";
				index = firstline.find(prefix, index);
				index += prefix.length();
				size_t rIndex = firstline.find('}', index);
				std::istringstream ss(firstline.substr(index, rIndex - index));
				ss >> cycle.High;
				index = rIndex;
			}

			if (cycle.Rate > 0)
			{
				cycles.push_back(cycle);
			}
			index = firstline.find('}', index);
			index++;
			if (firstline[index] == ']')
			{
				break;
			}
		}

		// Dump some cycling code
		std::wstring outputFile = destCodeFilename;
		std::ofstream out(outputFile);

		for (int i = 0; i < cycles.size(); ++i)
		{
			Cycle const& c = cycles[i];

			out << "    ; " << c.Low << "-" << c.High << " inclusive\n";
			out << "    LDA >#(LUT_START" << sceneIndex << " + (" << c.Low << " * 4))\n";
			out << "    STA src_pointer+1\n";
			out << "    LDA <#(LUT_START" << sceneIndex << " + (" << c.Low << "*4))\n";
			out << "    STA src_pointer\n";
			int cycleLength = c.High - c.Low;
			out << "    LDA #" << cycleLength << "; Cycle length\n";
			out << "    JSR CycleColors\n";
			out << "\n";
		}
	}
}

int main()
{
	WriteEmbedding(3);
	WriteEmbedding(5);
	WriteEmbedding(6);
	WriteEmbedding(8);
	WriteEmbedding(13);
	WriteEmbedding(16);
	WriteEmbedding(17);
	WriteEmbedding(18);
}
