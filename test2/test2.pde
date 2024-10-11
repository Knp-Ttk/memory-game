
int cols, rows; // Number of columns and rows
int totalCards; // Total number of cards
int[] cards; // Array to store card values
boolean[] revealed; // Array to track revealed cards
int firstCard = -1; // Index of the first selected card
int secondCard = -1; // Index of the second selected card
boolean checkMatch = false; // Flag to check if a match has been made
int pairsMatched = 0; // Number of pairs matched
int cardWidth, cardHeight;
boolean allowClick = true; // Control clicks during match checkw
int buttonHeight = 40; // Height of buttons
String difficulty = "4x5"; // Default difficulty
// multiplayer 
// hint aproximate
// timer
// Button positions and sizes
int btn2x5X = 10, btn2x5Y = 30;
int btn4x5X = 110, btn4x5Y = 30;
int btn8x5X = 210, btn8x5Y = 30;
int btn12x5X = 310, btn12x5Y = 30;
int btnWidth = 80;

String name = "Kanapong Tektrakul" ;
String id = "65-010126-3004-2" ;
void setup() {
  size(800, 800);
  
  // Initialize the game with the default difficulty
  initGame(difficulty);
}

void initGame(String difficulty) {
  // Set grid size based on difficulty level
  if (difficulty.equals("2x5")) {
    cols = 5;
    rows = 2;
  } else if (difficulty.equals("4x5")) {
    cols = 5;
    rows = 4;
  } else if (difficulty.equals("8x5")) {
    cols = 5;
    rows = 8;
  }
  else if (difficulty.equals("4x5 pro")) {
    cols = 5;
    rows = 4;
  }
  
  // Set card size and total number of cards
  totalCards = cols * rows;
  cardWidth = width / cols;
  cardHeight = (height - buttonHeight) / rows;
  
  // Initialize card arrays
  cards = new int[totalCards];
  revealed = new boolean[totalCards];
  pairsMatched = 0;
  
  // Create pairs of cards
  for (int i = 1; i < totalCards / 2; i++) {
    cards[i] = i;
    cards[i + totalCards / 2] = i;
  }
  
  // Shuffle the cards
  shuffle(cards);
  
  // Reset card selections
  firstCard = -1;
  secondCard = -1;
  checkMatch = false;
  allowClick = true;
  loop(); // Restart the game loop
}

void draw() {
  background(255);
  
  // Draw the buttons for difficulty selection
  drawButtons();
  
  // Draw the grid of cards
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int index = i + j * cols;
      if (revealed[index] || index == firstCard || index == secondCard) {
        // Show the card value
        fill(200);
        rect(i * cardWidth, j * cardHeight + buttonHeight, cardWidth, cardHeight);
        fill(0);
        textAlign(CENTER, CENTER);
        text(cards[index], i * cardWidth + cardWidth / 2, j * cardHeight + cardHeight / 2 + buttonHeight);
      } else {
        // Draw the back of the card
        fill(150);
        rect(i * cardWidth, j * cardHeight + buttonHeight, cardWidth, cardHeight);
      }
    }
  }

  // Check if we need to check for a match
  if (checkMatch && secondCard != -1) {
    allowClick = false; // Disable clicking while waiting for match check

    // Wait a short time to show both cards
    delay(500);

    // Check if the two selected cards match
    if (cards[firstCard] == cards[secondCard]) {
      revealed[firstCard] = true;
      revealed[secondCard] = true;
      pairsMatched++;
    }

    // Reset selected cards
    firstCard = -1;
    secondCard = -1;
    checkMatch = false;
    allowClick = true; // Re-enable clicking
  }

  // Win condition
  if (pairsMatched == totalCards / 2) {
    fill(0, 255, 0);
    textSize(32);
    textAlign(CENTER, CENTER);
    text("You Win!", width / 2, height / 2);
    noLoop(); // Stop the game
  }
}

void drawButtons() {
  // Draw buttons
  fill(150);
  rect(btn2x5X, btn2x5Y, btnWidth, buttonHeight);
  rect(btn4x5X, btn4x5Y, btnWidth, buttonHeight);
  rect(btn8x5X, btn8x5Y, btnWidth, buttonHeight);
  rect(btn12x5X, btn12x5Y, btnWidth, buttonHeight);
  fill(100,130,126);
  rect(410,10,200,buttonHeight);
  rect(650,10,100,buttonHeight);

  // Button labels
  fill(0);
  textAlign(CENTER, CENTER);
  text("easy", btn2x5X + btnWidth / 2, btn2x5Y + buttonHeight / 2);
  text("medium", btn4x5X + btnWidth / 2, btn4x5Y + buttonHeight / 2);
  text("hard", btn8x5X + btnWidth / 2, btn8x5Y + buttonHeight / 2);
  text("medium pro", btn12x5X + btnWidth / 2, btn12x5Y + buttonHeight / 2);
  text(id+"  "+name,410+200 /2 , 10 + buttonHeight /2);
}

void mousePressed() {
  // Check if a button is clicked
  if (mouseY > btn2x5Y && mouseY < btn2x5Y + buttonHeight) {
    if (mouseX > btn2x5X && mouseX < btn2x5X + btnWidth) {
      difficulty = "2x5";
      initGame(difficulty);
    } else if (mouseX > btn4x5X && mouseX < btn4x5X + btnWidth) {
      difficulty = "4x5";
      initGame(difficulty);
    } else if (mouseX > btn8x5X && mouseX < btn8x5X + btnWidth) {
      difficulty = "8x5";
      initGame(difficulty);
    }
     else if (mouseX > btn12x5X && mouseX < btn12x5X + btnWidth) {
      difficulty = "4x5 pro";
      initGame(difficulty);
    }
  }

  // Allow clicking only when not checking for a match
  if (allowClick && (firstCard == -1 || secondCard == -1)) {
    int i = mouseX / cardWidth;
    int j = (mouseY - buttonHeight) / cardHeight;
    
    // Ensure valid click within the grid
    if (mouseY > buttonHeight && i >= 0 && j >= 0 && i < cols && j < rows) {
      int index = i + j * cols;
      
      // Don't select revealed cards
      if (!revealed[index]) {
        if (firstCard == -1) {
          firstCard = index; // Select the first card
        } else if (secondCard == -1 && index != firstCard) {
          secondCard = index; // Select the second card
          checkMatch = true;  // Trigger match check
        }
      }
    }
  }
}

// Shuffle function to randomize the card positions
void shuffle(int[] array) {
  for (int i = 0; i < array.length; i++) {
    int r = int(random(array.length));
    int temp = array[i];
    array[i] = array[r];
    array[r] = temp;
  }
}
