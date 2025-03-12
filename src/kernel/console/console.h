// Text Mode Buffer
#define VGA_BUFFER 0xB8000
#define VGA_OFFSET_START (VGA_BUFFER + 320) // Start at 3rd line not to override protected mode message
#define VGA_BUFFER_END  0xBFFFF // Limit address of the buffer
#define VGA_PAGE_SIZE   0xFA0   // Page size (4000 bytes)
#define VGA_PAGE_COUNT  8       // Number of pages in the 32kB buffer
#define VGA_LINE_LENGTH 80      // Character length of one line (160 bytes)

// Colors
#define VGA_COLOR_BLACK        0x0
#define VGA_COLOR_BLUE         0x1
#define VGA_COLOR_GREEN        0x2
#define VGA_COLOR_CYAN         0x3
#define VGA_COLOR_RED          0x4
#define VGA_COLOR_PURPLE       0x5
#define VGA_COLOR_BROWN        0x6
#define VGA_COLOR_GRAY         0x7
#define VGA_COLOR_DARK_GRAY    0x8
#define VGA_COLOR_LIGHT_BLUE   0x9
#define VGA_COLOR_LIGHT_GREEN  0xA
#define VGA_COLOR_LIGHT_CYAN   0xB
#define VGA_COLOR_LIGHT_RED    0xC
#define VGA_COLOR_LIGHT_PURPLE 0xD
#define VGA_COLOR_YELLOW       0xE
#define VGA_COLOR_WHITE        0xF
// Font Color & Background Combinations
#define VGA_BLACK_ON_WHITE     (VGA_COLOR_BLACK | (VGA_COLOR_WHITE << 4))
#define VGA_BLACK_ON_GRAY      (VGA_COLOR_BLACK | (VGA_COLOR_GRAY << 4))
#define VGA_WHITE_ON_BLACK     (VGA_COLOR_WHITE | (VGA_COLOR_BLACK << 4))
#define VGA_RED_ON_BLACK       (VGA_COLOR_RED | (VGA_COLOR_BLACK << 4))
#define VGA_RED_ON_GRAY        (VGA_COLOR_RED | (VGA_COLOR_GRAY << 4))

typedef struct {
  volatile unsigned char* vga;
  unsigned char line;
  unsigned char col;
  unsigned char page;
} Console;

void printChar(char c);
void print(const char* str);
void println(const char* str);
void printAscii(unsigned int var);
void printHex(unsigned long var);
void updateOffset();
void newline();
