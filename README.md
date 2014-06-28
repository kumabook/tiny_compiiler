## Tiny Synth

Tiny synth is the synthesizer on stm32f4discovery.

### Development
1. Install gcc-arm-embedded and open-ocd below:

    ``` shell
        $curl -L -O https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q2-update/+download/	gcc-arm-none-eabi-4_8-2014q2-20140609-mac.tar.bz2
        $tar xjvf gcc-arm-none-eabi-4_8-2014q2-20140609-mac.tar.bz2
        $brew install open-ocd
    ```
2. Download STM32F4-Discovery Firm Ware V1.1.0:

   ``` shell
       $curl -O http://www.st.com/st-web-ui/static/active/en/st_prod_software_internet/	resource/technical/software/firmware/stsw-stm32068.zip
       $unzip stsw-stm32068.zip
   ```
3. Build

   ```
       $make
   ```
