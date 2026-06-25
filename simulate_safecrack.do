# ============================================================
# Script ModelSim - SafeCrack Pro
# Uso: no console do ModelSim, execute:
#      do simulate_safecrack.do
# OU pelo terminal:
#      vsim -do simulate_safecrack.do
# ============================================================

# ----- 1. Cria e entra na work library ----------------------
vlib work
vmap work work

# ----- 2. Compila os arquivos SV ----------------------------
# Flags:
#   -sv        -> habilita SystemVerilog
#   -O5        -> otimizacao maxima (opcional, acelera sim)
#   +acc       -> permite acesso a sinais internos no waveform

vlog -sv -O5 +acc safecrack_pro.sv
vlog -sv -O5 +acc safecrack_pro_tb.sv

# Se houver erro de compilacao, para aqui
if {[catch {vlog -sv safecrack_pro.sv safecrack_pro_tb.sv}]} {
    echo "ERRO: falha na compilacao. Verifique os arquivos .sv"
    return
}

# ----- 3. Carrega o testbench para simulacao ----------------
# -t ns  -> resolucao de tempo em nanosegundos
# +acc   -> acesso completo a hierarquia (necessario para add wave)
vsim -t ns +acc work.safecrack_pro_tb

# ----- 4. Configura a janela de formas de onda --------------
# Limpa o waveform anterior (se houver)
wave zoom full

# --- Entradas do DUT ---
add wave -divider "=== ENTRADAS ==="
add wave -label "CLOCK_50"   -color cyan    /safecrack_pro_tb/CLOCK_50
add wave -label "KEY[3:0]"   -color yellow  /safecrack_pro_tb/KEY

# --- Estado da FSM ---
add wave -divider "=== FSM ==="
add wave -label "estado"      -color orange  /safecrack_pro_tb/dut/estado
add wave -label "prox_estado" -color orange  /safecrack_pro_tb/dut/prox_estado

# --- Digitos digitados ---
add wave -divider "=== DIGITOS (decimal) ==="
add wave -label "digito0" -radix decimal /safecrack_pro_tb/dut/digito0
add wave -label "digito1" -radix decimal /safecrack_pro_tb/dut/digito1
add wave -label "digito2" -radix decimal /safecrack_pro_tb/dut/digito2
add wave -label "digito3" -radix decimal /safecrack_pro_tb/dut/digito3

# --- Displays 7 segmentos ---
add wave -divider "=== DISPLAYS 7-SEG ==="
add wave -label "HEX3 (dig0)" -radix binary /safecrack_pro_tb/HEX3
add wave -label "HEX2 (dig1)" -radix binary /safecrack_pro_tb/HEX2
add wave -label "HEX1 (dig2)" -radix binary /safecrack_pro_tb/HEX1
add wave -label "HEX0 (dig3)" -radix binary /safecrack_pro_tb/HEX0
add wave -label "HEX4 (pos)"  -radix binary /safecrack_pro_tb/HEX4

# --- LEDs de resultado ---
add wave -divider "=== LEDS ==="
add wave -label "LEDG (acerto)" -color green /safecrack_pro_tb/LEDG
add wave -label "LEDR (erro)"   -color red   /safecrack_pro_tb/LEDR

# --- Pulsos de debounce (internos ao DUT) ---
add wave -divider "=== PULSOS DEBOUNCE ==="
add wave -label "pulso0 (reset)"     /safecrack_pro_tb/dut/pulso0
add wave -label "pulso1 (confirma)"  /safecrack_pro_tb/dut/pulso1
add wave -label "pulso2 (inc)"       /safecrack_pro_tb/dut/pulso2
add wave -label "pulso3 (dec)"       /safecrack_pro_tb/dut/pulso3

# ----- 5. Executa a simulacao --------------------------------
# AVISO: a simulacao pode levar alguns minutos porque os timers
# de ACERTO (5s) e ERRO (3s) sao simulados em tempo real de clock
# (250.000.000 e 150.000.000 ciclos de 20ns cada).
#
# Para uma simulacao mais rapida (sem esperar os timers reais),
# veja o arquivo safecrack_pro_tb_fast.sv gerado abaixo.

echo ""
echo ">>> Iniciando simulacao... (pode demorar alguns minutos)"
echo ">>> Os testes de ACERTO e ERRO esperam 5s e 3s de clock."
echo ""

run -all

# ----- 6. Ajusta o zoom do waveform -------------------------
wave zoom full

echo ""
echo ">>> Simulacao concluida. Verifique o console acima para PASSOU/FALHOU."
echo ""
