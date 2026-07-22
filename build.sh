#!/bin/bash
echo "Menyiapkan Flutter untuk Vercel..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

echo "Memulai proses Build Flutter Web..."
flutter build web --release
echo "Build selesai!"
