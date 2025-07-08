# Devlog Entry 16 — Transition into KVM/QEMU Virtual Machine and the Optimization Process of its Performance

**Date**: 2025-07-07

**Author**: Emile Avoscan

**Target Version**: 0.6.0

## Main Objective

Since the beginning of the project the major tool utilized for testing the installation process was VirtualBox, but since the project has grown in scale and complexity Type 2 Virtualization proved to not be enough in terms of performance. This meant that a transition into a Type 1 was necessary, the most obvious options was KVM/QEMU. This devlog entry details the comprehensive process undertaken to configure and optimize a KVM/QEMU virtual machine intended for a graphical desktop environment, specifically AlmaLinux. The overarching goal was to resolve initial operational hurdles, specifically related to keyboard input passthrough, and subsequently address severe performance degradation, particularly in the graphical user interface, to achieve a more responsive and usable virtualized experience.

### Implementation

#### Keyboard Input Passthrough Configuration

The initial objective addressed was the misdirection of keyboard shortcuts, where host machine commands were being executed instead of those intended for the virtual machine.

The `virt-manager` preferences were accessed, and within the "Console" tab, the "Grab keys" setting was modified. A custom grab key combination was selected to ensure that keyboard input was correctly directed to the VM when its window was in focus. This modification was applied, and the virtual machine was subsequently restarted to ensure the changes took effect.

#### Memory Allocation and `qemu-guest-agent` Integration

Following the resolution of input passthrough, the virtual machine exhibited severe performance degradation, with `virt-manager` reporting "Memory usage: Disabled." This indicated a critical issue with memory reporting and potentially utilization within the guest OS.

An allocation of 4096 MiB (4GB) of RAM was configured for the virtual machine via `virt-manager`. Concurrently, the `qemu-guest-agent` was installed within the AlmaLinux guest OS. This involved updating package lists (`sudo dnf update -y`), installing the agent (`sudo dnf install -y qemu-guest-agent`), and then starting and enabling its associated `systemd` service (`sudo systemctl start qemu-guest-agent` and `sudo systemctl enable qemu-guest-agent`). A full reboot of the virtual machine was performed after these steps to ensure all changes were initialized.

#### VirtIO Channel Configuration for Guest Agent Communication

Despite the `qemu-guest-agent` installation, `virt-manager` continued to report "Memory usage: Disabled," and `systemctl status qemu-guest-agent` within the guest indicated a dependency on a non-existent unit (`dev-virtio\x2dports-org.qemu.guest_agent.0.device`). This pointed to a missing or improperly configured communication channel between the host and guest for the agent.

The virtual machine was powered off. A new "Channel" hardware device was added to the VM's configuration in `virt-manager`. The "Type" of this channel was specifically set to "QEMU vdagent," and its "Name" was manually configured to the precise string `org.qemu.guest_agent.0`. The VM was then started to allow the guest OS to detect and utilize this newly provisioned virtual serial port.

#### Host Resource Monitoring and Graphical Performance Assessment

Following the initial performance improvements, `btop` was utilized within the guest to monitor CPU and memory usage. This confirmed that the allocated memory was indeed being recognized and utilized by the guest OS, even if `virt-manager`'s dashboard did not reflect it. Additionally, `btop` was used on the host machine to assess its overall CPU utilization, which indicated significant idle capacity (approximately 67%). The observation that removing the `picom` compositor from the guest significantly improved graphical responsiveness strongly suggested that the primary performance bottleneck was within the virtualized graphics pipeline, rather than host CPU or guest memory availability.

### Challenges & Resolutions

* **Challenge**: Initial keyboard shortcuts (e.g., Mod + R) were being intercepted by the host OS instead of being passed to the VM.
    * **Resolution**: The "Grab keys" setting in `virt-manager` preferences was configured to a dedicated key combination, effectively directing keyboard input to the VM when its window was focused.

* **Challenge**: The virtual machine experienced severe sluggishness, with `virt-manager` reporting "Memory usage: Disabled," despite initial memory allocation.
    * **Resolution**: The `qemu-guest-agent` was installed and enabled within the AlmaLinux guest OS. This action aimed to establish proper memory reporting and management between the host and guest.

* **Challenge**: The `qemu-guest-agent` service within the AlmaLinux guest failed to start, indicating a dependency on a non-existent unit (`dev-virtio\x2dports-org.qemu.guest_agent.0.device`), even after agent installation. This indicated a communication channel issue, despite an existing "unix" channel.
    * **Resolution**: A dedicated "Channel" hardware device of type "QEMU vdagent" was added to the VM's configuration in `virt-manager`, with its name explicitly set to `org.qemu.guest_agent.0`. This provided the specific `virtio-serial` communication path required by the guest agent. Subsequent reboots of the VM (and host, as a general troubleshooting step) were performed to ensure device detection by the guest OS.

* **Challenge**: The VM remained less "snappy" than expected, particularly in graphical operations, even after addressing memory and agent issues, and despite low CPU and ample free memory reported by `btop` within the guest and idle CPU on the host. The `picom` compositor in the guest caused severe degradation.
    * **Resolution**: The `picom` compositor was removed from the AlmaLinux guest. This action confirmed that the primary bottleneck was the overhead associated with the virtualized graphics stack, particularly when burdened by a compositor. Further optimization efforts were identified as needing to focus on fine-tuning virtual GPU and display settings.

### Testing & Validation

Following each implementation step, direct observation of the VM's behavior was the primary validation method. Keyboard input was tested by attempting various Mod-key combinations. Performance was assessed qualitatively through interactive use of the graphical desktop environment and quantitatively via `btop` output within the guest. The `systemctl status qemu-guest-agent` command was executed within the guest after each configuration change related to the agent to confirm its operational state. `virt-manager`'s "Performance" tab was monitored to verify if memory usage reporting became active. Host `btop` was consistently reviewed to confirm host resource availability.

### Outcomes

The key-grabbing issue was successfully resolved, allowing seamless keyboard input within the VM. The `qemu-guest-agent` was successfully installed and the necessary `virtio-serial` channel was configured, ensuring that the guest OS could recognize and utilize its allocated memory (as validated by `btop` inside the VM). The critical "Memory usage: Disabled" status in `virt-manager`'s dashboard, however, persisted, indicating a specific reporting anomaly that warrants further investigation. The identification and subsequent removal of the `picom` compositor from the guest significantly improved graphical responsiveness, rendering the virtual machine usable, albeit not yet achieving the desired "snappiness." This process clearly highlighted virtualized graphical performance as the predominant area for further optimization.

## Reflection

This development cycle underscored the multifaceted nature of virtual machine performance optimization, particularly when integrating a graphical desktop environment. The initial challenge with keyboard input demonstrated the importance of foundational configuration. The subsequent deep dive into memory reporting and guest agent communication highlighted how subtle misconfigurations in virtual hardware, even with correct software installation in the guest, can lead to significant functional impairments. The persistent "Memory usage: Disabled" report in `virt-manager`, despite internal guest validation (via `btop`) showing otherwise, suggests a nuanced issue in the `libvirt`/`qemu-guest-agent` reporting pipeline that extends beyond simple driver presence. This warrants further research into specific `libvirt` XML configurations or `qemu-guest-agent` versions/capabilities that govern this metric.

The most critical learning was the significant impact of compositors on virtualized graphical performance. While KVM is lauded for its near-native CPU and I/O performance, the limitations of virtualized GPU rendering without direct passthrough became glaringly apparent. This experience reinforces the principle that while virtualization reduces hardware abstraction, the graphics stack remains a complex layer with inherent overhead. Future efforts must prioritize advanced graphical optimizations, potentially exploring `virtio-gpu-gl` (VirGL) if applicable for AlmaLinux and its desktop environment, or carefully tuning host-side graphics drivers to maximize performance for the virtual display server. The process also served as a reminder that CPU and memory are often not the primary bottlenecks in modern desktop virtualization; rather, it is frequently the intricate dance of graphical rendering through virtual hardware that dictates the user experience.

## Second Objective

The overarching goal was to achieve maximal performance purely through host-side configurations and `libvirt` XML modifications, critically adhering to the constraint that no changes, installations, or modifications were to be made within the guest operating system itself. This approach was necessitated by the use case of testing an installation process where guest integrity had to be preserved.

### Implementation

The implementation phase involved a multi-faceted approach, addressing CPU, storage I/O, and graphical performance bottlenecks through precise host-level and virtual machine configuration adjustments.

#### Host Kernel Parameter Configuration

The host's GRUB configuration was modified to include specific kernel parameters. `transparent_hugepage=never` was set to mitigate potential latency spikes associated with Transparent Huge Pages in virtualized environments. `intel_iommu=on` and `iommu=pt` were enabled to activate Intel VT-d (IOMMU), a prerequisite for advanced features such as mediated passthrough (GVT-g) and efficient `io=native` storage operations. Furthermore, `cpufreq.default_governor=performance` was configured to ensure the host CPU consistently operates at its highest frequency, providing stable and predictable performance for the virtual machines. Following these modifications, the GRUB configuration was updated, and the host system was rebooted for the changes to take effect.

#### Host `sysctl` Tuning

Kernel parameters were adjusted at runtime via `sysctl` to optimize resource management. A dedicated configuration file, `/etc/sysctl.d/99-kvm-performance.conf`, was created. Within this file, `fs.file-max` was increased to accommodate a higher number of open file descriptors, `vm.swappiness` was reduced to 10 to minimize the kernel's tendency to swap memory to disk, and `vm.dirty_background_ratio` and `vm.dirty_ratio` were tuned to 5 and 10 respectively, controlling the amount of memory used for dirty pages before they are written to disk. These adjustments were applied using `sudo sysctl -p`.

#### `irqbalance` Service Management

The `irqbalance` service was confirmed to be installed and actively running on the host. This service is crucial for distributing hardware interrupt requests (IRQs) efficiently across available CPU cores, thereby preventing any single core from becoming an I/O bottleneck and ensuring balanced resource utilization.

#### Virtual Machine CPU Configuration

The virtual machine's CPU definition within the `libvirt` XML was set to `mode='host-passthrough'`. This configuration instructs KVM to expose the exact CPU model and feature set of the host processor (Intel i5-8300H) directly to the guest, minimizing CPU feature emulation overhead and generally yielding superior performance. The CPU topology was also carefully defined to reflect the host's physical core count, with consideration for Hyper-Threading capabilities, allowing for optimal vCPU allocation.

#### CPU Pinning (`vcpupin` and `emulatorpin`)

CPU pinning was implemented to dedicate specific physical host CPU cores and threads to the VM's virtual CPUs and the QEMU emulator thread. This was achieved by adding a `<cputune>` section to the VM's XML, specifying `vcpupin` entries for each vCPU mapped to selected host CPU threads, and an `emulatorpin` entry to bind the QEMU process to the same set of host CPUs. This strategy significantly reduces context switching overhead and improves CPU cache efficiency.

#### Storage I/O Optimization (`virtio-blk` with Advanced Options)

For storage, the `virtio-blk` device was configured with advanced options to maximize I/O throughput and responsiveness. The `driver` element in the disk definition was set with `cache='none'` and `io='native'`. This bypasses the host's page cache and enables direct I/O to the underlying storage, providing consistent and high performance. For SSD-backed storage, `discard='unmap'` was included to enable TRIM operations from the guest, allowing the host SSD to reclaim unused blocks and maintain performance over time. Furthermore, `queues='8'` was set to allow the guest to issue multiple concurrent I/O requests, and an `<iothread id='1'/>` was assigned to offload I/O processing to a dedicated host thread, preventing the main QEMU thread from being burdened. A global `<iothreads>` section was also defined in the XML.

#### Graphical Performance Configuration (VirGL and GVT-g)

Two primary strategies were prepared for graphical performance enhancement:

1.  **VirGL (`virtio-gpu-gl`)**: The `<video>` device type was changed to `virtio`, and within the `<graphics type='spice'>` section, `<gl enable='yes'/>` was added. This configuration leverages VirGL to offload OpenGL rendering to the host's integrated Intel GPU, assuming the guest OS includes the necessary `virtio-gpu` drivers and `virglrenderer` support out-of-the-box.
2.  **Mediated Passthrough (GVT-g)**: This advanced option was prepared for implementation to provide near-native graphical performance. Host-side setup involved enabling `i915.enable_gvt=1`, `i915.enable_guc=0`, and `i915.enable_fbc=0` in GRUB, loading `kvmgt` and `vfio_mdev` kernel modules, and creating a mediated device (mdev) for the Intel iGPU. The VM's XML was then configured to remove existing `<video>` devices and incorporate the newly created mdev as a `<hostdev>` device. This method relies on the guest OS automatically detecting and utilizing the virtualized Intel GPU.

#### Memory Ballooning Deactivation

To ensure fixed and consistent memory allocation, the `memballoon` device was set to `model='none'` in the VM's XML. This prevents dynamic memory adjustments by the host, which can sometimes introduce latency, ensuring the VM always has its allocated RAM available.

### Challenges & Resolutions

* **Challenge**: Initial attempts included guest-side modifications (e.g., installing `spice-vdagent` and configuring it via `systemctl`). This contradicted the core project constraint of keeping the guest OS untouched for installation testing purposes.
    * **Resolution**: The approach was fundamentally re-evaluated. All subsequent optimization strategies were strictly limited to host-side configurations (kernel parameters, `sysctl`, `irqbalance`) and `libvirt` XML modifications (CPU, storage, graphics device selection and tuning). This ensured adherence to the "no guest modification" constraint.

* **Challenge**: The `spice-vdagent.service` was reported as non-existent when attempting to enable it via `systemctl enable --now spice-vdagent.service` within the guest.
    * **Resolution Attempt**: It was clarified that `spice-vdagent` often runs as a user service (`systemctl --user`) or is automatically launched by the desktop environment. However, since guest modifications were ultimately disallowed, this specific troubleshooting path was not pursued further. The focus shifted to host-side graphical solutions that do not require guest-side agent installation, such as VirGL and GVT-g, which rely on drivers already present in the guest's default installation.

### Testing & Validation

Verification of the implemented changes would be performed primarily from the host's perspective, with observations of guest behavior. CPU performance improvements would be inferred from the `host-passthrough` and CPU pinning configurations, aiming for reduced latency and improved responsiveness. Storage I/O performance would be validated using host-side tools like `iostat` and `iotop` to monitor disk activity of the VM's image file, ensuring optimal throughput and low latency under load. Graphical performance would be assessed by observing the fluidity of the desktop environment within the VM, with specific validation for VirGL or GVT-g by checking `glxinfo -B` output within the guest (assuming it's part of the default installation's diagnostic tools) to confirm the virtual GPU is active and providing hardware acceleration.

### Outcomes

The implementation of these host-centric KVM/QEMU optimizations is expected to yield a significantly more responsive and performant graphical desktop experience for the AlmaLinux guest VMs, even without any internal guest modifications. CPU utilization should be more efficient due to `host-passthrough` and pinning, reducing overhead. Storage I/O operations are anticipated to be faster and more consistent with `cache='none'`, `io='native'`, and `discard='unmap'`, leading to quicker boot times and application launches. Most critically, the strategic configuration of virtual graphics (VirGL or GVT-g) from the host is projected to resolve the observed graphical sluggishness, providing a smoother desktop experience essential for validating the installation process.

## Reflection

This development cycle underscored the critical importance of clearly defined constraints in technical problem-solving. The initial misdirection regarding guest-side modifications highlighted how assumptions can lead to inefficient solutions. The pivot to a purely host-centric optimization strategy was a valuable lesson in adapting approaches to meet stringent requirements. It reinforced the understanding that for use cases where guest integrity is paramount, leveraging the full capabilities of the hypervisor and host hardware through meticulous configuration is the most effective path. The iterative process of identifying bottlenecks (graphical sluggishness, low CPU utilization despite free resources) and then mapping them to specific host-side KVM/QEMU features proved to be an efficient methodology. This work contributes to a more robust and performant virtualization environment, directly supporting the project's goal of reliable installation process testing.

## Final Objective

The final goal was to implement an optimized GPU virtualization method for KVM/QEMU. The primary constraint for this initiative was the absolute prohibition of any modifications or installations within the guest OS, necessitating all optimizations to be strictly host-side or VM XML-based. The overarching goal was to achieve the best possible performance for the virtualized graphical desktop experience within these parameters.

### Implementation

The optimization process involved a series of iterative refinements to the KVM host configuration and the virtual machine's libvirt XML definition. Each step aimed to enhance specific performance vectors, including CPU, storage I/O, and graphical rendering.

#### Initial VM XML Configuration

The existing VM XML was analyzed to identify baseline configurations. Key components such as memory allocation, vCPU count, and default device types were noted. The initial display method was VNC, and the disk driver was `qcow2` with `discard='unmap'`.

#### CPU Performance Enhancements

CPU optimization was implemented by leveraging `host-passthrough` mode and precise CPU pinning. The `<cpu>` element was configured to expose the host CPU's exact features to the guest, allowing for highly optimized instruction sets. Furthermore, a `<cputune>` block was introduced to dedicate specific host CPU cores to the VM's vCPUs and the QEMU emulator thread, minimizing context switching overhead. This involved pinning `vcpu`s to host cores `1`, `2`, and `3`, and the `emulatorpin` to host core `0`. The `kvmclock` timer was also explicitly enabled within the `<clock>` section, and `<kvm><hidden state='on'/></kvm>` was added to `<features>` for improved timekeeping.

#### Storage I/O Performance Enhancements

Storage I/O was addressed by refining the `virtio-blk` disk driver. The `cache` attribute was set to `none` (optimal for SSDs) to bypass host caching and prevent double caching. The `io` mode was set to `native` to utilize asynchronous I/O (`libaio`), enhancing concurrency. The `queues` attribute was set to `4` (matching the vCPU count) to enable multi-queue virtio-blk, improving throughput. An `iothread` with `id='1'` was explicitly defined within the `<devices>` section and linked to the disk driver via `iothread='1'`, aiming to dedicate a host thread for disk I/O. The `discard='unmap'` attribute was maintained for TRIM support on SSDs.

#### Graphical Performance Attempt 1: Enhanced QXL/SPICE

Initial efforts focused on optimizing QXL and SPICE, as they are standard paravirtualized graphics solutions. The `<video>` model was set to `qxl` with `vram='65536'` (64MB) and `accel3d='yes'`, `accel2d='yes'` were enabled. The `<graphics>` type was configured as `spice` with `gl enable='yes'` and `rendernode='/dev/dri/renderD128'` to enable OpenGL acceleration via SPICE.

#### Graphical Performance Attempt 2: `virtio` Video Model

Following issues with QXL, the video model was switched to `virtio`. The `<video>` element's `type` attribute was changed from `qxl` to `virtio`, maintaining `vram='65536'` and `heads='1'`. The `<acceleration>` tag was later removed as it is not supported by the `virtio` video model in QEMU. The `<graphics type='spice'>` configuration was retained, anticipating that `virtio-gpu` with SPICE would provide accelerated rendering via VirGL.

#### Graphical Performance Attempt 3: Intel GVT-g (Mediated Passthrough)

A more advanced approach, Intel GVT-g, was attempted to provide near-native graphical performance by creating a virtual GPU (vGPU) on the host's integrated Intel HD Graphics 530. This involved several host-side kernel and module configurations:
* **BIOS/UEFI Configuration:** "Intel Virtualization Technology for Directed I/O" (VT-d/IOMMU) was enabled, and CPU C-states were disabled for reduced latency. Intel Turbo Boost and SpeedStep were confirmed enabled.
* **Kernel Parameters:** The `GRUB_CMDLINE_LINUX` variable in `/etc/default/grub` was updated to include `intel_iommu=on i915.enable_gvt=1 i915.enable_guc=0`. This change was applied using `grubby --update-kernel=ALL --args="..."` to ensure it was picked up by the Boot Loader Specification (BLS) configuration.
* **Module Loading:** The `vfio_mdev` and `kvmgt` kernel modules were intended to be loaded via `sudo modprobe`.
* **VM XML for GVT-g:** The `<video>` and `<graphics>` sections were removed from the VM XML. A `<hostdev>` element was introduced, referencing a unique UUID for the vGPU instance (`<address uuid='YOUR_UUID'/>`) and assigned a unique PCI address within the VM. A minimal `<graphics type='vnc'>` was included for console access.

#### Final Graphical Configuration: VNC Fallback

Due to persistent issues with both SPICE and GVT-g, the graphical configuration was reverted to a basic VNC display. The `<graphics>` section was set to `type='vnc'` with `port='-1'` and `autoport='yes'`, and the `<video>` model remained `virtio`.

### Challenges & Resolutions

* **Challenge**: Initial VM sluggishness, even with low CPU/RAM usage, suggesting a graphical bottleneck.
    * **Resolution**: This observation guided the focus towards graphical performance optimizations (QXL/SPICE, VirGL, GVT-g) as primary objectives.
* **Challenge**: Incorrect placement of the `<graphics>` XML element, leading to libvirt validation errors.
    * **Resolution**: The `<graphics>` element was correctly positioned as a direct child of the `<devices>` element, separate from `<video>`.
* **Challenge**: PCI address conflict when assigning the `<video>` device, resulting in "Attempted double use of pcie address" error.
    * **Resolution**: An unused PCI slot (`0x00:0x07.0`) was identified and assigned to the `<video>` device, resolving the conflict.
* **Challenge**: `iothread` not defined error (`Disk iothread '1' not defined in iothreadid`) despite `iothread id='1'` and `iothreadpin` being present.
    * **Resolution Attempt 1**: Initially, a whitespace issue was suspected and corrected.
    * **Resolution Attempt 2**: The `iothread` definition was explicitly moved to be *before* any disk devices.
    * **Resolution**: Ultimately, all `iothread` related configurations (`<iothread id='1'/>`, `iothread='1'` in disk driver, `iothreadpin` in `cputune`) were removed from the XML due to persistent incompatibility, allowing VM definition to proceed.
* **Challenge**: "domain configuration does not support video model 'qxl'" error.
    * **Resolution**: This indicated a lack of QXL support in the QEMU packages. The `<video>` model was changed from `qxl` to `virtio`, which is explicitly supported and generally preferred.
* **Challenge**: "qemu does not support the accel2d setting" error with the `virtio` video model.
    * **Resolution**: The `<acceleration accel3d='yes' accel2d='yes'/>` tag was removed from the `<video>` section, as explicit 2D acceleration settings are not used with `virtio-gpu`.
* **Challenge**: "spice graphics are not supported with this QEMU" error after `virtio` model was accepted.
    * **Resolution**: Extensive `dnf search` commands confirmed that QEMU packages in AlmaLinux 9 repositories do not include SPICE support. This is a deliberate upstream decision by Red Hat. SPICE was determined to be unavailable.
* **Challenge**: `vfio_mdev` and `kvmgt` kernel modules not found for Intel GVT-g.
    * **Resolution**: `modprobe` commands failed, indicating these modules are not present in the standard AlmaLinux 9 kernel or its supplementary packages. This confirmed that Intel GVT-g is not natively supported by the distribution without custom kernel compilation or third-party repositories.
* **Challenge**: Kernel parameters (`intel_iommu=on`, `i915.enable_gvt=1`, `i915.enable_guc=0`) added to `/etc/default/grub` were not applied to `/proc/cmdline` after reboot.
    * **Resolution**: It was identified that the system uses Boot Loader Specification (BLS) configuration. The parameters were successfully applied using `sudo grubby --update-kernel=ALL --args="..."`, which directly modifies the BLS entries.
* **Challenge**: BIOS setting for "VT for direct I/O" (Intel VT-d/IOMMU) was initially off.
    * **Resolution**: This critical setting was enabled in the BIOS/UEFI, which is fundamental for any form of device passthrough.
* **Challenge**: CPU C-states were enabled in BIOS.
    * **Resolution**: CPU C-states were disabled in BIOS to reduce potential latency and jitter for the VM.

### Testing & Validation

Verification and validation were conducted iteratively after each significant change:

* **XML Validation:** `virsh edit <VM_NAME>` was used, which performs real-time XML schema validation. Any errors were immediately addressed.
* **Kernel Parameters:** `cat /proc/cmdline` was used post-reboot to confirm kernel boot arguments were correctly applied. `dmesg | grep -i iommu` was used to check IOMMU status.
* **Module Loading:** `lsmod | grep <module_name>` was used to confirm kernel modules (`i915`, `vfio_mdev`, `kvmgt`, `mdev`) were loaded.
* **GVT-g Device Presence:** `ls /sys/bus/pci/devices/0000\:00\:02.0/mdev_supported_types/` was used to check for vGPU type availability.
* **VM Definition:** `virsh define alma.xml` was executed to ensure the VM XML was accepted by libvirt.
* **VM State:** `virsh list --all` was used to confirm the VM's defined status.
* **VM Start:** `virsh start almalinux9` was used to attempt VM boot.
* **Graphical Connection:** `virt-viewer` was used to connect to the VM's console, and `virsh vncdisplay almalinux9` was used to identify the VNC port.

### Outcomes

The development cycle concluded with the successful definition and execution of the AlmaLinux 9 KVM VM. Significant performance optimizations were applied to the CPU and storage I/O subsystems, including `host-passthrough`, CPU pinning, and optimized `virtio-blk` driver settings. However, due to inherent limitations in the AlmaLinux 9 distribution's QEMU/kernel packages, hardware-accelerated graphical output (via SPICE/VirGL or Intel GVT-g) was determined to be unsupported. The VM's graphical display was ultimately configured to use VNC, which provides basic console access but relies on software rendering within the guest. The overall system responsiveness for non-graphical tasks is expected to be significantly improved, but the optimization of the virtualized GPU was a complete failure due to direct limitations of the specific implementation of the Linux Kernel on RHEL-based distributions. Almalinux9 being one of them.

## Reflection

This development cycle provided profound insights into the nuances of KVM virtualization on enterprise-grade Linux distributions. The persistent challenges encountered with graphical acceleration highlight a critical divergence in feature priorities between stable server-oriented distributions like AlmaLinux/RHEL and more bleeding-edge or desktop-focused Linux variants.

The initial assumption that standard paravirtualized graphics solutions (QXL/SPICE) or even mediated passthrough (GVT-g) would be readily available was disproven by the distribution's package choices. This underscores the importance of thorough environmental and package availability checks early in a project, especially when targeting specific, non-standard features on a given OS.

The iterative debugging process, characterized by systematic elimination of variables and precise XML modifications, proved invaluable. Each error message, though frustrating at the time, served as a precise guide to the next step, ultimately revealing the fundamental constraint of the host OS's capabilities. The reliance on `grubby` for kernel parameter management in BLS-enabled systems was a key learning point.

Ultimately, this experience reinforces that while KVM is a highly capable hypervisor, its full potential is realized only when the host operating system's kernel and user-space components are aligned with the desired virtualization features. For scenarios demanding high-performance graphical VMs, a distribution with a more aggressive stance on desktop virtualization features (e.g., Fedora, Ubuntu) would be a more suitable choice, accepting the trade-off of potentially less long-term stability. This project served as a rigorous exercise in identifying and navigating such architectural limitations in a professional virtualization environment.
