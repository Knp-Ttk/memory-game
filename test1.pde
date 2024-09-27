int rows = 4;
int cols = 5;
float w, h; // Width and height of each button
int[] numbers; // To hold the random numbers
boolean[] flip; // To track flipped buttons
int lastClickedIndex = -1;
int secondLastClickedIndex = -1;

// Set up the canvas and initialize arrays
void setup() {
  size(500, 400);
  w = width / cols;
  h = height / rows;

  numbers = generateRandomNumbers(10);
  flip = new boolean[rows * cols];
}

// Draw the grid of buttons and numbers
void draw() {
  background(255);
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      int index = i * cols + j;
      float x = j * w;
      float y = i * h;

      // Draw button background
      if (flip[index]) {
        fill(200, 255, 200); // Green if flipped
      } else {
        fill(200); // Gray if not flipped
      }
      rect(x, y, w, h);

      // Show the number if flipped
      if (flip[index]) {
        fill(0);
        textAlign(CENTER, CENTER);
        text(numbers[index], x + w / 2, y + h / 2);
      }
    }
  }
}

// Detect mouse presses and flip the appropriate button
void mousePressed() {
  int i = floor(mouseY / h);
  int j = floor(mouseX / w);
  int index = i * cols + j;

  if (index >= 0 && index < rows * cols && !flip[index]) {
    flipNumber(index);
  }
}

// Flip a button and check for matching logic
void flipNumber(int index) {
  flip[index] = true;

  if (lastClickedIndex != -1) {
    if (numbers[lastClickedIndex] == numbers[index] && lastClickedIndex != index) {
      // Match: Keep them flipped
      lastClickedIndex = -1;
      secondLastClickedIndex = -1;
    } else {
      // No match: Flip back after delay
      if (secondLastClickedIndex != -1) {
        flip[secondLastClickedIndex] = false;
        flip[lastClickedIndex] = false;
      }
      secondLastClickedIndex = lastClickedIndex;
      lastClickedIndex = index;
    }
  } else {
    lastClickedIndex = index;
  }
}

// Generate an array of random pairs of numbers
int[] generateRandomNumbers(int pairCount) {
  int[] nums = new int[pairCount * 2];
  int count = 0;
  while (count < pairCount * 2) {
    int num = int(random(1, pairCount + 1));
    int occurrences = 0;
    for (int i = 0; i < count; i++) {
      if (nums[i] == num) occurrences++;
    }
    if (occurrences < 2) {
      nums[count] = num;
      count++;
    }
  }
  return nums;
}
