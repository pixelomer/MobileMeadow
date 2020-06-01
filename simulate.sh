set -e
MEADOW_USE_SIMULATOR=1 make
echo "Installing for simulator..."
sudo rm -rv /opt/simject/MobileMeadow
sudo cp -v .theos/obj/iphone_simulator/debug/MobileMeadow.dylib /opt/simject/
sudo cp -rv layout/Library/MobileMeadow /opt/simject/
sudo codesign -f -v -s - /opt/simject/MobileMeadow.dylib
resim all