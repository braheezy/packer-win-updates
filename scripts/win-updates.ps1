# Install PSWindowsUpdates module
# Use module to get list of KBs required
# Download all KBs (Can the module do this?)
# Install all KBs to patch current system
# Use DISM to capture folder of KBs as data image
# Create ZIP file of KBs
# Use Packer file provisioner to download artifacts back to host