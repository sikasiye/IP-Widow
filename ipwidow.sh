#!/usr/bin/env bas


# ============================================
#  IP WIDOW - Domain to IP Hunter Tool
#  Author: Mr H👾X
#  GitHub: https://github.com/sikasiye/IP-Widow.git
#  Version: 1.0
#  License: MIT
#  Created: 2025
# ============================================

# Written by Mr H👾X
# IP WIDOW - Domain to Server IP Tool

# Banner

GREEN='\033[0;32m'
RESET='\033[0m'

show_banner() {
    echo -e "${GREEN}"
    echo "  ┌────────────────────┐"
    echo "  │  ██╗██████╗        │"
    echo "  │  ██║██╔══██╗       │"
    echo "  │  ██║██████╔╝       │"
    echo "  │  ██║██╔═══╝        │"
    echo "  │  ██║██║            │"
    echo "  │  ╚═╝╚═╝            │"
    echo "  │     W I D O W      │"
    echo "  │                    │"
    echo "  │  created by        │"
    echo "  │    Mr H👾X         │"
    echo "  └────────────────────┘"
    echo -e "${RESET}"
}

show_banner



# Check if URL argument is provided
if [ -z "$1" ]; then
    echo -e "\n[!] Usage: $0 <domain or URL>"
    echo -e "[+] Example: $0 google.com"
    echo -e "[+] Example: $0 https://github.com\n"
    exit 1
fi

# Extract domain from URL (remove http://, https://, www., and trailing paths)
INPUT="$1"
DOMAIN=$(echo "$INPUT" | sed -e 's|^[a-zA-Z]*://||' -e 's|/.*$||' -e 's|^www\.||')

echo -e "\n[*] Resolving domain: $DOMAIN\n"

# Function to resolve IP using multiple methods
resolve_ip() {
    local domain="$1"
    local ip=""
    
    # Method 1: dig (most reliable)
    if command -v dig &> /dev/null; then
        ip=$(dig +short "$domain" A | head -1 | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi
    
    # Method 2: host
    if command -v host &> /dev/null; then
        ip=$(host "$domain" 2>/dev/null | grep 'has address' | head -1 | awk '{print $4}' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi
    
    # Method 3: nslookup
    if command -v nslookup &> /dev/null; then
        ip=$(nslookup "$domain" 2>/dev/null | grep -A1 'Name:' | tail -1 | awk '{print $2}' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi
    
    # Method 4: ping (fallback)
    if command -v ping &> /dev/null; then
        ip=$(ping -c 1 "$domain" 2>/dev/null | head -1 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi
    
    return 1
}

# Resolve IPv4 address
IPV4=$(resolve_ip "$DOMAIN")
if [ -n "$IPV4" ]; then
    echo -e "[+] IPv4 Address: $IPV4"
    
    # Optional: Perform reverse DNS lookup
    if command -v dig &> /dev/null; then
        PTR=$(dig -x "$IPV4" +short | head -1)
        if [ -n "$PTR" ]; then
            echo -e "[+] Reverse DNS: $PTR"
        fi
    fi
    
    # Optional: Show geolocation info (requires curl and ip-api.com)
    if command -v curl &> /dev/null; then
        echo -e "\n[*] Fetching geolocation data..."
        GEO=$(curl -s "http://ip-api.com/line/$IPV4?fields=country,city,isp,org")
        if [ -n "$GEO" ]; then
            echo -e "[+] Country: $(echo "$GEO" | sed -n 1p)"
            echo -e "[+] City: $(echo "$GEO" | sed -n 2p)"
            echo -e "[+] ISP: $(echo "$GEO" | sed -n 3p)"
            echo -e "[+] Organization: $(echo "$GEO" | sed -n 4p)"
        fi
    fi
else
    echo -e "[!] Failed to resolve IP address for $DOMAIN"
    echo -e "[*] Check your network connection or domain spelling"
    exit 1
fi

# Try to find all IPv4 addresses (load balancing)
echo -e "\n[*] Attempting to find all associated IPv4 addresses..."
ALL_IPS=$(dig +short "$DOMAIN" A | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
if [ -n "$ALL_IPS" ]; then
    COUNT=$(echo "$ALL_IPS" | wc -l)
    echo -e "[+] Found $COUNT IP address(es):"
    echo "$ALL_IPS" | while read -r ip; do
        echo "    → $ip"
    done
else
    echo -e "[!] No additional IPs found"
fi

# IPv6 support (optional)
echo -e "\n[*] Checking for IPv6 address..."
IPV6=$(dig +short "$DOMAIN" AAAA | head -1 | grep -E '^[a-fA-F0-9:]+$')
if [ -n "$IPV6" ]; then
    echo -e "[+] IPv6 Address: $IPV6"
else
    echo -e "[-] No IPv6 address found"
fi

echo -e "\n[✓] Resolution complete.\n"
exit 0
