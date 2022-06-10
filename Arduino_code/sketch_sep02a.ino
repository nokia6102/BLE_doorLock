#include <SoftwareSerial.h>

#include <Wire.h>
#include <Servo.h>

Servo myservo; // 建立Servo物件，控制伺服馬達


// the maximum received command length from an Android system (over the bluetooth)

#define MAX_BTCMDLEN 128



// 建立一個軟體模擬的序列埠; 不要接反了!

// HC-06    Arduino

// TX       RX/Pin12

// RX       TX/Pin11

SoftwareSerial BTSerial(12, 11); // Arduino RX/TX



byte cmd[MAX_BTCMDLEN]; // received 128 bytes from an Android system

int len = 0; // received command length



void setup() {
  
  Serial.begin(9600);   // Arduino起始鮑率：9600

  BTSerial.begin(9600); // HC-06 出廠的鮑率：每個藍牙晶片的鮑率都不太一樣，請務必確認


//  pinMode(3, OUTPUT);
//  myservo.attach(3, 500, 2400); // 修正脈衝寬度範圍
  myservo.attach(9);    //ping is D6
  myservo.write(120); // 一開始先移到30度
  delay(300);
}



void loop() {

  char str[MAX_BTCMDLEN];

  int insize, ii;

  int tick = 0;

  while ( tick < MAX_BTCMDLEN ) { // 因為包率同為9600, Android送過來的字元可能被切成數份

    if ( (insize = (BTSerial.available())) > 0 ) { // 讀取藍牙訊息

      for ( ii = 0; ii < insize; ii++ ) {

        cmd[(len++) % MAX_BTCMDLEN] = char(BTSerial.read());

      }

    } else {

      tick++;

    }

  }

  if (len) { // 用串列埠顯示從Android手機傳過來的訊息

    
    sprintf(str, "%s", cmd);
    // For motor
    if(str[0] == 79 || str[0] == 'o') {  // o
//      for(int i = 500; i <= 2400; i+=100){
//        myservo.writeMicroseconds(i); // 直接以脈衝寬度控制
        Serial.println(1);
        Serial.println(str);
        myservo.write(30);
        delay(300);
        Serial.println(myservo.read());
//      }
    } else if (str[0] == 67 || str[0] == 'c') {  // C
//      for(int i = 2400; i >= 500; i-=100){
//        myservo. (i);
        Serial.println(2);
        Serial.println(str);
        myservo.write(120);
        delay(300);
        Serial.println(myservo.read());
//      }
    }

    

    

    cmd[0] = '\0';

  }

  len = 0;

}
