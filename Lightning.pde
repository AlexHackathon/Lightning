//To Do: Fix displays and player numbers and scores
import processing.serial.*;

int round;
int totalRounds;
int treeCount;
Forest forest;
int currentPlayerIndex;
int playerCount;
ArrayList<Player> playerList;
ArrayList<Player> playersAlive;

void setup(){
  background(0.0,0);
  stroke(255,255,255);
  size(400,400);
  
  round = 1;
  totalRounds = 3;
  playerCount = 2;
  currentPlayerIndex = 0;
  playerList = new ArrayList<Player>();
  playersAlive = new ArrayList<Player>();
  for(int i = 0; i < playerCount; i++){
    Player p = new Player(-20, height, 5);
    p.listIndex = i;
    playerList.add(p);
    playersAlive.add(p);
  }
 
  treeCount = 20;
  forest = new Forest(treeCount);
  forest.placePlayer(playersAlive.get(currentPlayerIndex));
}
void mouseClicked(){
  if(round <= totalRounds){
    if(mouseX >= 150 && mouseX <= 250 && mouseY >= 120 && mouseY <= 170){
      //If the round is ending
      playersAlive.get(currentPlayerIndex).endTurn();
      forest.reset();
      currentPlayerIndex += 1;
      if(currentPlayerIndex >= playersAlive.size()){
        currentPlayerIndex = 0;
        round += 1;
      }
      forest.placePlayer(playersAlive.get(currentPlayerIndex));
    } else {
      //If the forest is being struck
      if(playersAlive.size() == 0 || round > totalRounds){
        round = 4;
      } else {
        System.out.println("MouseClicked");
        playersAlive.get(currentPlayerIndex).addPoint();
        forest.strikeForest(playersAlive.get(currentPlayerIndex));
        if(playersAlive.get(currentPlayerIndex).alive){
          if(forest.forest.size() == 1){
            playersAlive.get(currentPlayerIndex).endTurn();
            currentPlayerIndex += 1;
            if(currentPlayerIndex >= playersAlive.size()){
              currentPlayerIndex = 0;
              round += 1;
            }
            forest.reset();
            forest.placePlayer(playersAlive.get(currentPlayerIndex));
          }
        } else {
          playersAlive.remove(currentPlayerIndex);
          forest.reset();
          currentPlayerIndex += 1;
          if(currentPlayerIndex >= playersAlive.size()){
            currentPlayerIndex = 0;
            round += 1;
          }
          if(playersAlive.size() == 0){
            round = 4;
          } else{
            forest.placePlayer(playersAlive.get(currentPlayerIndex));
          }
          System.out.println("Player died");
        }
      }
    }
  }
}

void draw(){
  forest.drawForest();
  if(round <= totalRounds){
    fill(0,0,0,30);
    rect(0,0,400,400);
    fill(255,255,255);
    textAlign(CENTER);
    textSize(30);
    text("Round " + round, 200, 30);
    textSize(25);
    
    text("Player " + (int)(playersAlive.get(currentPlayerIndex).listIndex + 1), 200, 60);
    textSize(15);
    text("Round Score " + (int)playersAlive.get(currentPlayerIndex).roundScore, 200, 90);
    textSize(15);
    text("Score " + (int)playersAlive.get(currentPlayerIndex).score, 200, 110);
    fill(20,20,20);
    rect(150, 120, 100, 50);
    fill(255,255,255);
    text("End round", 200, 150);
  } else {
    fill(0,0,0,30);
    rect(0,0,400,400);
    forest.drawForest();
    fill(255,255,255);
    textAlign(CENTER);
    textSize(30);
    text("Game Over ", 200, 30);
    textSize(15);
    for(int i = 0; i < playerList.size(); i++){
      int displayNum = playerList.get(i).listIndex + 1;
      text("Player " + displayNum, 150, 60 + i * 30);
      text(playerList.get(i).score, 250, 60 + i * 30);
    }
  }
}
class Forest {
  ArrayList<StrikeableObject> forest;
  int[] indexList;
  int treeCount;
 
  public Forest(int treeNum){
    this.treeCount = treeNum;
    this.forest = new ArrayList<StrikeableObject>();
    for(int i = 0; i < this.treeCount; i++){
      forest.add(new Tree((float)width/(2*this.treeCount) + i * (float)width/ this.treeCount, height, 10, 3));
    }
    this.drawForest();
  }
  public void drawForest(){
    for(int i = 0; i < this.forest.size(); i++){
      this.forest.get(i).drawObject();
    }
  }
  public void strikeForest(Player currPlayer){
    int randomIndex = (int)(Math.random() * this.forest.size());
    this.drawLightning(this.forest.get(randomIndex).getPos(), 400, 10,10);
    System.out.println("Striking");
    if(this.forest.get(randomIndex) instanceof Player){
      System.out.println("Striking a player");
      currPlayer.alive = false;
    }    
    if(forest.size() == 0){
      this.reset();
      playerList.get(currentPlayerIndex).endTurn();
      round += 1;
    }
    this.forest.remove(randomIndex);
  }
  public void drawLightning(float groundX, float groundY, float maxStepX, float maxStepY){
    float currentX = groundX;
    float currentY = groundY;
    float nextX;
    float nextY;
    while(currentY > 0){
     if(Math.random() >= .5f){
       nextX = (float)(currentX + Math.random()*maxStepX);
     } else {
       nextX = (float)(currentX - Math.random()*maxStepX);
     }
     nextY = (float)(currentY - Math.random() * maxStepY);
     line(currentX, currentY, nextX, nextY);
     currentX = nextX;
     currentY = nextY;
    }
  }
  public void reset(){
    forest = new ArrayList<StrikeableObject>();
    for(int i = 0; i < this.treeCount; i++){
      forest.add(new Tree((float)width/(2*this.treeCount) + i * (float)width/ this.treeCount, height, 10, 3));
    }
  }
  public void placePlayer(Player player){
    int playerIndex = (int)(Math.random() * this.forest.size());
    player.posX = (float)width/(2*this.forest.size()) + playerIndex * (float)width/ this.forest.size();
    this.forest.set(playerIndex, player);
  }
}

class StrikeableObject{
  public float posX;
  public float posY;
  public int baseUnit;
  public void drawObject(){
   
  }
  public float getPos(){
    return posX;
  }
}
class Tree extends StrikeableObject{
  public float posX;
  public float posY;
  int baseUnit;
  int leaves;
 
  public Tree(float x, float y, int unit, int leafCount){
    this.posX = x;
    this.posY = y;
    this.baseUnit = unit;
    this.leaves = leafCount;
  }
 
  public void drawObject(){
    fill(67,7,7);
    stroke(255,255,255);
    rect(posX-.5*baseUnit, posY - (leaves + 1) * baseUnit, baseUnit, (leaves + 1) *baseUnit);
    fill(33,160,8);
    for(int i = 0; i < leaves; i++){
      triangle(posX, posY - (i + 3) * baseUnit, posX + 1.5*baseUnit, posY - (i+1) * baseUnit, posX - 1.5 * baseUnit, posY - (i+1) * baseUnit);
    }
  }  
  public float getPos(){
    return posX;
  }
}
class Player extends StrikeableObject{
  int score;
  int roundScore;
  int listIndex;
  boolean alive;
 
  public Player(float x, float y, int unit){
    this.score = 0;
    this.roundScore = 0;
    this.alive = true;
    this.posX = x;
    this.posY = y;
    this.baseUnit = unit;
    this.drawObject();
  }
  public void drawObject(){
    fill(0,0,0);
    stroke(255,255,255);
    line(this.posX, this.posY - 2 * this.baseUnit, this.posX + this.baseUnit, this.posY);
    line(this.posX, this.posY - 2 * this.baseUnit, this.posX - this.baseUnit, this.posY);
    line(this.posX, this.posY - 2 * this.baseUnit, this.posX, this.posY - 6*this.baseUnit);
    line(this.posX + this.baseUnit, this.posY - 6*this.baseUnit, this.posX - this.baseUnit, this.posY - 3*this.baseUnit);
    ellipse(this.posX, this.posY - 7*this.baseUnit, 2 * baseUnit, 2*baseUnit);
  }
  public float getPos(){
    return posX;
  }
  public void addPoint(){
    this.roundScore += 1;
  }
  public void endTurn(){
    this.score += this.roundScore;
    this.roundScore = 0;
  }
}
