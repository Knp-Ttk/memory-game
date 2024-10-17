// Game variables
int cols, rows;
int totalCards;
int[] cards;
boolean[] revealed;
int firstCard = -1;
int secondCard = -1;
boolean checkMatch = false;
int pairsMatched = 0;
int cardWidth, cardHeight;
boolean allowClick = true;
String difficulty = "4x5"; // Normal by default
boolean devMode = false;
int currentPlayer = 1;
String playerTurn = "Player 1's Turn";
boolean singlePlayer = true;

// Multiplayer score
int player1Score = 0;
int player2Score = 0;

// Timer variables
int gameStartTime; // Start time for game timer
boolean isPaused = false; // Pause state
int elapsedTime = 0; // Total time played

// Button positions and sizes
int btnSingleX = 60, btnSingleY = 90;
int btnMultiX = 170, btnMultiY = 90;
int btn2x5X = 60, btn2x5Y = 150; // Adjusted position
int btn4x5X = 160, btn4x5Y = 150; 
int btn8x5X = 260, btn8x5Y = 150; 
int btnDoubleNormalX = 360, btnDoubleNormalY = 150;  // New Double Normal button
int btnHintX = 60, btnHintY = 210; // Adjusted position
int btnDevModeX = 160, btnDevModeY = 210; 
int btnPauseX = 260, btnPauseY = 210; // Position for Pause/Resume button
int btnWidth = 90;
int btnHeight = 40; // Increased height

boolean isHidingHint = false; // Flag for hiding hint
int hintStartTime = 0; // Time when the hint was shown
int hintDuration = 2000; // Duration to show the hint (2 seconds)

// Fonts
PFont customFont;

// Background color
color bgColor;

// Variables for flip animation
boolean isFlipping = false;
float flipAngle = 0; // Angle for flip animation
int flippingCard = -1; // Index of the card being flipped

// Variables for slow disappearance
boolean isHiding = false;
int hideStartTime = 0;
int hideDelay = 2000; // 2 seconds delay before hiding unmatched cards

void setup() {
  size(1600, 960); // Expanded to 1080x720 resolution

  // Set up background color
  bgColor = color(50, 150, 200);
  
  // Load custom font
  customFont = createFont("Arial Bold", 32);
  textFont(customFont);
  
  initGame(difficulty);
}

void initGame(String difficulty) {
  if (difficulty.equals("2x5")) {
    cols = 5;
    rows = 2;
  } else if (difficulty.equals("4x5")) {
    cols = 5;
    rows = 4;
  } else if (difficulty.equals("8x5")) {
    cols = 5;
    rows = 8;
  } else if (difficulty.equals("Double Normal")) {  // New Double Normal Mode
    cols = 5;
    rows = 4;
  }

  totalCards = cols * rows;
  cardWidth = (width - 40) / cols; // Adjusted spacing
  cardHeight = (height - 320) / rows; // Adjusted height for the new resolution

  cards = new int[totalCards];
  revealed = new boolean[totalCards];
  pairsMatched = 0;

  if (difficulty.equals("Double Normal")) {
    // In Double Normal, each number from 1-5 has two pairs (total 20 cards for 4x5 grid)
    for (int i = 0; i < 5; i++) {
      cards[i] = i + 1;
      cards[i + 5] = i + 1;
      cards[i + 10] = i + 1;
      cards[i + 15] = i + 1;
    }
  } else {
    // Normal modes: each number has one pair
    for (int i = 0; i < totalCards / 2; i++) {
      cards[i] = i + 1;
      cards[i + totalCards / 2] = i + 1;
    }
  }

  shuffleArray(cards); // Shuffle the cards array

  firstCard = -1;
  secondCard = -1;
  checkMatch = false;
  allowClick = true;
  currentPlayer = 1;
  playerTurn = "Player 1's Turn";
  player1Score = 0;
  player2Score = 0;

  gameStartTime = millis(); // Start the game timer
  elapsedTime = 0; // Reset elapsed time

  isFlipping = false;
  flipAngle = 0;
  flippingCard = -1;
  isHiding = false;
  hideStartTime = 0;

  loop();
}

void draw() {
    background(bgColor); // Set the background color

    drawButtons(); // Call the drawButtons function to handle drawing buttons

    // Draw boards based on the game mode
    drawBoard(20, 270); // Adjusted the x and y coordinates for better fit on the screen

    // Display win message
    if (pairsMatched == totalCards / 2) {
        fill(0, 255, 0);
        textSize(32);
        textAlign(CENTER, CENTER);

        if (singlePlayer) {
            // Single player mode win
            text("You Win!", width / 2, height / 2);
        } else {
            // Multiplayer mode win based on score
            if (player1Score > player2Score) {
                text("Player 1 Wins!", width / 2, height / 2);
            } else if (player2Score > player1Score) {
                text("Player 2 Wins!", width / 2, height / 2);
            } else {
                text("It's a Tie!", width / 2, height / 2); // In case of a tie
            }
        }

        noLoop(); // Stop the game loop for win message
    }

    // Update the timer if the game is not paused
    if (!isPaused) {
        elapsedTime = (millis() - gameStartTime) / 1000; // Update elapsed time in seconds
        fill(0);
        textSize(18);
        text("Time: " + elapsedTime + "s", width - 120, 30);
    } else {
        // Display paused message
        fill(0);
        textSize(18);
        textAlign(CENTER, CENTER);
        text("Game Paused", width / 2, 240);
    }

    // Handle hiding unmatched cards after delay
    if (isHiding && millis() - hideStartTime > hideDelay) {
        revealed[firstCard] = false;
        revealed[secondCard] = false;
        resetCards();
        isHiding = false;
        changePlayerTurn(); // Switch turns in multiplayer mode
    }

    // Check cards outside draw loop to ensure it happens after drawing is complete
    checkCards();
    if (isHidingHint && millis() - hintStartTime > hintDuration) {
        isHidingHint = false; // Reset the flag
    }
    if (isHintVisible) {
    if (firstCard != -1) {
      int matchingCard = -1;

      // Find the matching card for the currently selected card
      for (int i = 0; i < totalCards; i++) {
        if (cards[i] == cards[firstCard] && i != firstCard && !revealed[i]) {
          matchingCard = i;
          break;
        }
      }

      if (matchingCard != -1) {
        // Show the hint with the position of the matching card
        int row = matchingCard / cols;
        int col = matchingCard % cols;
        fill(255, 255, 0);
        textAlign(CENTER, CENTER);
        textSize(24);
        text("Hint: Pair is at (" + (col + 1) + ", " + (row + 1) + ")", width / 2, 240);
      }
    }
  }
}



void drawBoard(int x, int y) {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int index = i + j * cols;
      float posX = x + i * cardWidth + cardWidth / 2;
      float posY = y + j * cardHeight + cardHeight / 2;

      pushMatrix();
      translate(posX, posY);

      // Handle flip animation
      if (isFlipping && (index == flippingCard)) {
        flipAngle += 10; // Increment flip angle
        if (flipAngle >= 180) {
          flipAngle = 0;
          isFlipping = false;
          flippingCard = -1;
        }
      }

      // Calculate scale based on flip angle
      float scaleX = abs(cos(radians(flipAngle)));
      scale(scaleX, 1);

      // Determine if the card is face up
      boolean isFaceUp = revealed[index] || index == firstCard || index == secondCard;

      // Draw card
      if (isFaceUp) {
        fill(255);
        strokeWeight(3);
        stroke(0);
        rectMode(CENTER);
        rect(0, 0, cardWidth - 10, cardHeight - 10, 10);

        // Draw the number as Roman numeral
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(32);
        text(convertToRoman(cards[index]), 0, 0);
      } else {
        fill(100, 100, 255);
        strokeWeight(3);
        stroke(0);
        rectMode(CENTER);
        rect(0, 0, cardWidth - 10, cardHeight - 10, 10);

        // Show card number in dev mode
        if (devMode) {
          fill(255, 0, 0);
          textSize(12);
          textAlign(RIGHT, BOTTOM);
          text(cards[index], cardWidth / 2 - 15, cardHeight / 2 - 15);
        }
      }

      popMatrix();
    }
  }

  // Display player scores
  fill(0);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("Player 1: " + player1Score, 10, 30);
  text("Player 2: " + player2Score, 10, 60);
  text(playerTurn, width / 2, 160);
}

void drawButtons() {
    // Draw the buttons
    drawButton(btnSingleX, btnSingleY, btnWidth, btnHeight, "Single");
    if (isMouseOver(btnMultiX, btnMultiY, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btnMultiX, btnMultiY, btnWidth, btnHeight, "Multi");

    if (isMouseOver(btn2x5X, btn2x5Y, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btn2x5X, btn2x5Y, btnWidth, btnHeight, "Easy");

    if (isMouseOver(btn4x5X, btn4x5Y, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btn4x5X, btn4x5Y, btnWidth, btnHeight, "Normal");

    if (isMouseOver(btn8x5X, btn8x5Y, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btn8x5X, btn8x5Y, btnWidth, btnHeight, "Hard");

    // Draw Double Normal button
    if (isMouseOver(btnDoubleNormalX, btnDoubleNormalY, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btnDoubleNormalX, btnDoubleNormalY, btnWidth, btnHeight, "Double");

    if (isMouseOver(btnHintX, btnHintY, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btnHintX, btnHintY, btnWidth, btnHeight, "Hint");

    if (isMouseOver(btnDevModeX, btnDevModeY, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btnDevModeX, btnDevModeY, btnWidth, btnHeight, "Dev Mode");

    if (isMouseOver(btnPauseX, btnPauseY, btnWidth, btnHeight)) {
        fill(200, 200, 255);
    } else {
        fill(150, 150, 255);
    }
    drawButton(btnPauseX, btnPauseY, btnWidth, btnHeight, isPaused ? "Resume" : "Pause"); // Pause/Resume button

    // Text for name and ID
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("Kanapong Tektrakul | ID: 65-010126-3004-2", width / 2, 20);
}

void drawButton(int x, int y, int w, int h, String label) {
  stroke(255);
  strokeWeight(2);
  rect(x, y, w, h, 10); // Rounded corners

  fill(255);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(label, x + w / 2, y + h / 2);
}

boolean isMouseOver(int x, int y, int w, int h) {
  return (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h);
}

void mousePressed() {
  // Prevent interaction when hiding unmatched cards
  if (isHiding || isFlipping) return;

  // Handle clicks on buttons
  // Single Player Button
  if (isMouseOver(btnSingleX, btnSingleY, btnWidth, btnHeight)) {
    singlePlayer = true;
    initGame(difficulty);
    return;
  }

  // Multiplayer Button
  if (isMouseOver(btnMultiX, btnMultiY, btnWidth, btnHeight)) {
    singlePlayer = false;
    initGame(difficulty);
    return;
  }

  // Difficulty Buttons
  if (isMouseOver(btn2x5X, btn2x5Y, btnWidth, btnHeight)) {
    difficulty = "2x5"; // Easy
    initGame(difficulty);
    return;
  }
  if (isMouseOver(btn4x5X, btn4x5Y, btnWidth, btnHeight)) {
    difficulty = "4x5"; // Normal
    initGame(difficulty);
    return;
  }
  if (isMouseOver(btn8x5X, btn8x5Y, btnWidth, btnHeight)) {
    difficulty = "8x5"; // Hard
    initGame(difficulty);
    return;
  }
  if (isMouseOver(btnDoubleNormalX, btnDoubleNormalY, btnWidth, btnHeight)) {
    difficulty = "Double Normal"; // Double Normal
    initGame(difficulty);
    return;
  }

  // Handle Pause/Resume button click
  if (isMouseOver(btnPauseX, btnPauseY, btnWidth, btnHeight)) {
    togglePause();
    return;
  }

  // Handle Hint button click
  if (isMouseOver(btnHintX, btnHintY, btnWidth, btnHeight)) {
    giveHint();
    return;
  }

  // Handle Dev Mode button click
  if (isMouseOver(btnDevModeX, btnDevModeY, btnWidth, btnHeight)) {
    devMode = !devMode;
    return;
  }

  // Handle card click
  if (allowClick && mouseY > 270) {
    int cardIndex = getCardAt(mouseX, mouseY);

    if (cardIndex != -1 && !revealed[cardIndex] && cardIndex != firstCard && cardIndex != secondCard) {
      flipCard(cardIndex);
    }
  }
}

int getCardAt(int x, int y) {
  int col = (x - 20) / cardWidth;
  int row = (y - 270) / cardHeight;

  if (col >= 0 && col < cols && row >= 0 && row < rows) {
    return col + row * cols;
  }
  return -1;
}

void shuffleArray(int[] array) {
  // Fisher-Yates shuffle algorithm
  for (int i = array.length - 1; i > 0; i--) {
    int j = int(random(i + 1));
    // Swap array[i] with array[j]
    int temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
}

void checkCards() {
  if (checkMatch) {
    if (cards[firstCard] == cards[secondCard]) {
      revealed[firstCard] = true;
      revealed[secondCard] = true;
      pairsMatched++;
      
      // Update the score for multiplayer
      if (!singlePlayer) {
        if (currentPlayer == 1) {
          player1Score++;
        } else {
          player2Score++;
        }
      }

      resetCards();
    } else {
      // Start the hiding timer
      isHiding = true;
      hideStartTime = millis();
    }
    checkMatch = false;
  }
}

void flipCard(int cardIndex) {
  if (isFlipping) return;

  if (firstCard == -1) {
    firstCard = cardIndex;
  } else if (secondCard == -1) {
    secondCard = cardIndex;
    checkMatch = true;
    allowClick = false;
  }

  // Start flip animation
  isFlipping = true;
  flippingCard = cardIndex;
}

void resetCards() {
  firstCard = -1;
  secondCard = -1;
  allowClick = true;
  isFlipping = false;
  flipAngle = 0;
  flippingCard = -1;
}

void changePlayerTurn() {
  currentPlayer = (currentPlayer == 1) ? 2 : 1;
  playerTurn = "Player " + currentPlayer + "'s Turn";
}
boolean isHintVisible = false; // Flag to control hint visibility

void giveHint() {
  // Toggle the hint visibility
  if (!isHintVisible) {
    if (firstCard != -1) {
      int matchingCard = -1;

      // Find the matching card for the currently selected card
      for (int i = 0; i < totalCards; i++) {
        if (cards[i] == cards[firstCard] && i != firstCard && !revealed[i]) {
          matchingCard = i;
          break;
        }
      }

      if (matchingCard != -1) {
        // Show the hint with the position of the matching card
        int row = matchingCard / cols;
        int col = matchingCard % cols;
        fill(255, 255, 0);
        textAlign(CENTER, CENTER);
        textSize(24);
        text("Hint: Pair is at (" + (col + 1) + ", " + (row + 1) + ")", width / 2, 240);

        // Keep hint visible until next click
        isHintVisible = true;
      }
    }
  } else {
    // If hint is already visible, hide it
    isHintVisible = false;
  }
}

// Pause and resume the game
void togglePause() {
    isPaused = !isPaused; // Toggle the paused state
    if (isPaused) {
        // When paused, capture the current elapsed time
        elapsedTime = (millis() - gameStartTime) / 1000; // Capture elapsed time in seconds
    } else {
        // When resuming, reset gameStartTime to continue counting
        gameStartTime = millis() - (elapsedTime * 1000); // Resume timer from where it paused
    }
}

// Timer display
void updateTimer() {
    if (isPaused) {
        fill(0);
        textSize(18);
        textAlign(CENTER, CENTER);
        text("Game Paused", width / 2, 240);
    } else {
        elapsedTime = (millis() - gameStartTime) / 1000; // Update elapsed time in seconds
    }
}


// Roman numeral conversion function
String convertToRoman(int number) {
  String[] romanNumerals = {
    "I", "II", "III", "IV", "V", 
    "VI", "VII", "VIII", "IX", "X",
    "XI", "XII", "XIII", "XIV", "XV",
    "XVI", "XVII", "XVIII", "XIX", "XX"
  };
  
  if (number >= 1 && number <= 20) {
    return romanNumerals[number - 1];
  } else {
    return String.valueOf(number);
  }
}
