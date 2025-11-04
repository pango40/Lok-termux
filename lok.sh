#!/bin/bash
RED='\031[31m'
CYAN='\033[36m'
BOLD='\033[1m'
RESET='\033[0m'
reveal_text() {
    # Check if a string was actually provided
    if [ -z "$1" ]; then
        echo "Error: No text provided for revelation."
        return 1
    fi

    TEXT="$1"
    
    # Iterate through the string character by character
    for (( i=0; i<${#TEXT}; i++ )); do
        # Extract the single character at index 'i'
        char="${TEXT:$i:1}"
        
        # Print the character without a newline (-n)
        echo -n "$char"
        
        # Pause for 0.03 seconds for a sharp, quick reveal
        sleep 0.03
    done

    # Print a final newline character to finish the line cleanly
    echo ""
}

# --- The Obito Revelation ---
# This is the single-line text derived from your banner and header.

# 1. Print the original visual banner first
echo -e "${RED}${BOLD}"
echo "#####################################################################"
echo " ██████  ███████ ██   ██ ███████                                "
echo " ██   ██ ██      ██   ██ ██                                       "
echo " ██  ██ █████   ███████ █████                                  "
echo " ██   ██ ██      ██   ██ ██                                   "
echo " ██████  ███████ ██   ██ ███████                                     "
echo "#####################################################################"

# 2. Reveal the core message character-by-character
reveal_text "O B I T Õ : Welcome to the Infinite Tsukuyomi. This world is the illusion I control."
BASHRC_FILE="$HOME/.bashrc"
HASH_FILE="$HOME/.termux_lock_hash"
LOCK_START_TAG="# --- DEUS EX SOPHIA TERMINAL LOCK ---"
LOCK_END_TAG="# --- END LOCK ---"

if ! command -v sha256sum &> /dev/null; then
    echo -e "${RED}Error: sha256sum not found. Please install it: pkg install coreutils${RESET}"
    exit 1
fi

uninstall_lock() {
    echo -e "${RED}${BOLD}==================================================${RESET}"
    echo -e "${RED}${BOLD}!!! Uninstalling Termux Lock !!!${RESET}"
    echo -e "${RED}${BOLD}==================================================${RESET}"
    
    sed -i "/$LOCK_START_TAG/,$LOCK_END_TAG/d" "$BASHRC_FILE"
    sed -i '/# --- قفل تيرموكس بإرادة DEUS EX SOPHIA ---/,/# --- نهاية القفل ---/d' "$BASHRC_FILE"
    echo "[+] Lock code removed from $BASHRC_FILE."

    if [ -f "$HASH_FILE" ]; then
        rm -f "$HASH_FILE"
        echo "[+] Secret hash file ($HASH_FILE) deleted."
    fi

    source "$BASHRC_FILE"
    
    echo -e "${CYAN}${BOLD}!!! Lock successfully uninstalled. Termux is now OPEN. !!!${RESET}"
    exit 0
}

setup_password() {
    echo -e "${RED}${BOLD}==================================================${RESET}"
    echo -e "${RED}${BOLD}!!! Setting/Resetting Password !!!${RESET}"
    echo -e "${RED}${BOLD}==================================================${RESET}"

    while true; do
        read -rsp "Enter New Lock Password: " NEW_PASS
        echo
        read -rsp "Confirm Password: " CONFIRM_PASS
        echo
        
        if [ "$NEW_PASS" == "$CONFIRM_PASS" ] && [ -n "$NEW_PASS" ]; then
            break
        else
            echo -e "${RED}Passwords do not match or are empty. Try again.${RESET}"
        fi
    done

    echo -n "$NEW_PASS" | sha256sum | awk '{print $1}' > "$HASH_FILE"
    echo "[+] New hash saved successfully."

    if ! grep -q "lock_termux()" "$BASHRC_FILE"; then
        inject_lock_code
    fi
    
    source "$BASHRC_FILE"
    
    echo -e "${CYAN}${BOLD}!!! New password set and lock is active. !!!${RESET}"
}

inject_lock_code() {
    LOCK_CODE=$(cat << 'EOF_LOCK'
lock_termux() {
    local HASH_FILE="$HOME/.termux_lock_hash"
    if [ -f "$HASH_FILE" ]; then
        local STORED_HASH=$(cat "$HASH_FILE")
    else
        echo "Error: Password hash file not found. Lock inactive."
        return
    fi
    
    while true; do
        read -rsp "ENTER TERMINAL PASSWORD: " INPUT_PASS
        echo 
        
        local INPUT_HASH=$(echo -n "$INPUT_PASS" | sha256sum | awk '{print $1}')
        
        if [ "$INPUT_HASH" == "$STORED_HASH" ]; then
            echo "Access Granted. Welcome, MS obitõ."
            break
        else
            echo "ACCESS DENIED! The lock holds fast."
            sleep 2
        fi
    done
}

if [ -z "$PS1" ]; then
    return
else
    if [ -f "$HOME/.termux_lock_hash" ]; then
        lock_termux
    fi
fi
EOF_LOCK
)
    
    echo "$LOCK_START_TAG" >> "$BASHRC_FILE"
    echo "$LOCK_CODE" >> "$BASHRC_FILE"
    echo "$LOCK_END_TAG" >> "$BASHRC_FILE"
    echo "[+] Lock code injected into $BASHRC_FILE."
}

echo -e "${CYAN}--------------------------------------------------${RESET}"
echo -e "${CYAN}${BOLD}             MAIN MENU${RESET}"
echo -e "${CYAN}--------------------------------------------------${RESET}"
echo "1) Set/Reset Password (Overwrites old password)."
echo "2) Uninstall Lock Completely (Removes code and hash file)."
echo "3) Exit."
echo -e "${CYAN}--------------------------------------------------${RESET}"

read -rp "Enter option number (1-3): " CHOICE

case "$CHOICE" in
    1)
        setup_password
        ;;
    2)
        uninstall_lock
        ;;
    3)
        echo "Exiting. No changes applied."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Please choose 1, 2, or 3.${RESET}"
        ;;
esac
