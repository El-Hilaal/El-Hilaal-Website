#!/bin/bash

# Configuratie variabelen
ORIGINAL_URL="https://elhilaal.nl"
FALLBACK_URL="https://el-hilaal.github.io/El-Hilaal-Website/"
CHECK_INTERVAL=60
LOG_FILE="/var/log/website_monitor.log"
MAINTENANCE_PAGE="/var/www/html/maintenance.html"

# Functie om te controleren of website bereikbaar is
check_website() {
    if curl --output /dev/null --silent --head --fail --max-time 10 "$ORIGINAL_URL"; then
        return 0  # succes
    else
        return 1  # falen
    fi
}

# Functie om maintenance pagina te maken
create_maintenance_page() {
    cat > "$MAINTENANCE_PAGE" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Website Onderhoud</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #d9534f; }
        a { color: #337ab7; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>De website is tijdelijk niet beschikbaar</h1>
    <p>Onze excuses voor het ongemak. We werken aan een oplossing.</p>
    <p>U kunt onze alternatieve website bezoeken op: 
       <a href="$FALLBACK_URL">$FALLBACK_URL</a>
    </p>
</body>
</html>
EOF
}

# Hoofdlogica
main() {
    while true; do
        if check_website; then
            # Website is up, verwijder maintenance pagina als die bestaat
            if [ -f "$MAINTENANCE_PAGE" ]; then
                rm "$MAINTENANCE_PAGE"
                echo "$(date) - Website is terug online, maintenance pagina verwijderd" >> "$LOG_FILE"
            fi
        else
            # Website is down, maak maintenance pagina aan
            create_maintenance_page
            echo "$(date) - Website is down, maintenance pagina getoond" >> "$LOG_FILE"
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Start het script
main