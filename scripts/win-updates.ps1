<#
This Windows Updates (WUs) approach focuses on .msu files

Why .msu vs the many other ways to deal with and reason about WUs?
- A simple mental model. Your updates are normal files that are familiar to work with
- Very transferable e.g. offline, airgapped
#>

# Install PSWindowsUpdates module
# Use module to get list of KBs required
# Download all KBs (Can the module do this?)
# Install all KBs to patch current system
# Use DISM to capture folder of KBs as data image
# Create ZIP file of KBs
# Use Packer file provisioner to download artifacts back to host