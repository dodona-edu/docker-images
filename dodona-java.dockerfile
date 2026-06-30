# Transition alias for dodona-edu/dodona#7583: `dodona-java` is the new, version-less
# name for the modern Java image (currently Java 25, still built as `dodona-java21`).
# For now it just mirrors `dodona-java21` so both names are published while we migrate
# the consumers. In the final step the real Dockerfile moves here and `dodona-java21`
# is removed.
# hadolint ignore=DL3007
FROM ghcr.io/dodona-edu/dodona-java21:latest
