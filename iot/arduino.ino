#include <WiFi.h>
#include <HTTPClient.h>

// Configurações de Wi-Fi
const char* ssid = "[nome wifi]"; // Substitua pelo nome da sua rede Wi-Fi
const char* password = "[senha wifi]"; // Substitua pela senha da sua rede Wi-Fi

// URL do backend
const char* serverName = "https://[codigo].execute-api.us-east-1.amazonaws.com/default/funcaoMonitorUV";

// Pino do sensor UV UVM-30A
const int uvPin = A0;

// Variáveis de leitura
float uvLevel = 0.0;

void setup() {
  Serial.begin(115200);

  // Conectar ao Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConectado ao Wi-Fi");
}

void loop() {
  // Leitura do sensor
  int uvRaw = analogRead(uvPin);
  uvLevel = uvRaw * (5.0 / 1024.0); // Converter para tensão (0-5V)
  
  // Calcular índice UV com base na tensão do sensor
  float uvIndex = uvLevel * 10.0; // Ajuste conforme a calibração do sensor

  Serial.print("UV Index: ");
  Serial.println(uvIndex);

  // Enviar dados para o backend
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    // Dados a serem enviados
    String jsonData = String("{\"location\": \"Itapira-Centro\", \"level\": ") +
                      String(uvIndex, 2) +
                      ", \"status\": \"" +
                      getUVStatus(uvIndex) +
                      "\", \"lastUpdate\": \"" +
                      getTimestamp() +
                      "\"}";

    int httpResponseCode = http.POST(jsonData);

    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);

    http.end();
  } else {
    Serial.println("Falha na conexão Wi-Fi");
  }

  delay(60000); // Atualizar a cada 1 minuto
}

// Retornar o status UV com base no índice UV
String getUVStatus(float uvIndex) {
  if (uvIndex <= 2.0) return "Baixo";
  else if (uvIndex <= 5.0) return "Moderado";
  else if (uvIndex <= 7.0) return "Alto";
  else if (uvIndex <= 10.0) return "Muito Alto";
  else return "Extremo";
}

// Retornar timestamp no formato "dd/MM/yyyy - HH:mm"
String getTimestamp() {
  time_t now = time(nullptr);
  struct tm* timeinfo = localtime(&now);
  char buffer[30];
  strftime(buffer, sizeof(buffer), "%d/%m/%Y - %H:%M", timeinfo);
  return String(buffer);
}
