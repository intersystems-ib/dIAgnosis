FROM ollama/ollama:latest

COPY /ollama/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]