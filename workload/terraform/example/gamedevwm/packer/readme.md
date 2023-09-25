# Packer Configuration for creating an Azure Virtual Desktop Image for a Game Developer
<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#Trademarks">Trademarks</a></li>
    <li><a href="#Reportingissues">Reporting issues</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Contains the Packer configuration files for building a custom AVD image for a game developer. The image is based on Azure ARM and includes a setup of custom scripts (PowerShell) and configuration for setting up the the image.

Packer is a tool for creating identical machine images for multiple platforms from a single source configuration.

The files are a series of provisioners, which are used to install and configure software within a Packer-built machine image.

### Built With

* [Packer.io](Packer-url)
<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

Before you can use this Packer configuration, you will need to have the following software installed on your system:

- [Packer](https://www.packer.io/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

You will also need to have an Azure subscription and have the necessary permissions to create and manage virtual machines.

Prior to running packer build create a resource group name `rg_gmdv_packer`

### Installation

To install the Packer configuration, follow these steps:

1. Clone this repository to your local machine.
2. Open a terminal or command prompt and navigate to the root directory of the repository.
3. Run the following command to build the virtual machine image:

   ```
   packer build .
   ```

   This command will create a new virtual machine image based on the Packer configuration. The process may take several minutes to complete.


<!-- USAGE EXAMPLES -->
## Usage

To use the virtual machine image, follow these steps:

1. Open the Azure portal and navigate to the virtual machines section.
2. Click the "Create a virtual machine" button.
3. Select the "Custom Images" option and choose the virtual machine image created by Packer.
4. Follow the prompts to configure the virtual machine and create it.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

There are many ways in which you can participate in this project, for example:
[Submit bugs and feature requests](https://github.com/Azure/avdaccelerator/issues), and help us verify as they are checked in

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.

<!-- LICENSE -->
## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Reporting issues
Microsoft Support is not yet handling issues for any published tools in this repository. However, we would like to welcome you to open issues using GitHub [issues](https://github.com/Azure/avdaccelerator/issues) to collaborate and improve these tools.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Packer.io]: https://www.packer.io

