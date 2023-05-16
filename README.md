<h1 align="center">
    <img
        src=".github/git-pull-request.svg"
        alt=""
        width="50"
        height="50"
        align="center"
    />
    Pull Request Tracker
</h1>

<p align="center">A GitHub Action to track <b>similar</b> or <b>duplicated</b> Pull Requests.<br><i>"A maintainers must-have!"</i> - Me.</p>

<div align="center">
</div>

<div align="center">
    <a href="https://www.gnu.org/software/bash/">
        <img
            src="https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white"
            alt="Shell Script"
        />
    </a>
    <a href="https://github.com/features/actions">
        <img
            src="https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white"
            alt="GitHub Actions"
        />
    </a>
    <a href="https://github.com/sponsors/mateusabelli">
        <img
            src="https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA"
            alt="GitHub Sponsors"
        />
    </a>
</div>

<br>

> **Warning** This project is under development.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Features

- Automatically gets triggered with new Pull Requests.
- Analyzes all open Pull Requests that modify the same files.
- Checks if there are merge conflicts among the Pull Requests found.
- Creates a detailed comment on the newly created Pull Request.

### Modules

- [x] Check pulls
- [x] Check conflicts
- [ ] Check hunks (In development)

### How it works

```mermaid
flowchart LR
	787551(["Start"]) --> 546805("Check Pulls")
	linkStyle 0 stroke:#b1b1b6
	546805 --> 201075("Check Conflicts")
	linkStyle 1 stroke:#b1b1b6
	201075 --> 832927("Comment")
	linkStyle 2 stroke:#b1b1b6
	832927 --> 288295(["End"])
	linkStyle 3 stroke:#b1b1b6
```

<details>

<summary>Detailed flowchart</summary>

```mermaid
flowchart TD
	737386("Check Pulls") --> 885552{"Found Pull Requests?"}
	linkStyle 0 stroke:#b1b1b6
	885552 -->|"Yes"| 147358[/"Exports new \nenvironment <span>variables</span>"/]
	linkStyle 1 stroke:#b1b1b6
	885552 -->|"No"| 301196["Do nothing"]
	linkStyle 2 stroke:#b1b1b6
	147358 --> 170819("Check Conflicts")
	linkStyle 3 stroke:#b1b1b6
	170819 --> 120741{"Found \nConflicts?"}
	linkStyle 4 stroke:#b1b1b6
	120741 -->|"Yes"| 860237[/"Exports new \nenvironment variables"/]
	linkStyle 5 stroke:#b1b1b6
	120741 -->|"No"| 611854["Do nothing"]
	linkStyle 6 stroke:#b1b1b6
	860237 --> 343045("Comment")
	linkStyle 7 stroke:#b1b1b6
	349329{"Has new \nenvironment variables?"} -->|"Yes"| 299642[\"Assumes failure and\n<span>write detailed comment</span>"\]
	linkStyle 8 stroke:#b1b1b6
	349329 -->|"No"| 463077[\"Assumes success <span>and</span>\n<span>write </span><span>simple comment</span>"\]
	linkStyle 9 stroke:#b1b1b6
	299642 --> 264246(["End"])
	linkStyle 10 stroke:#b1b1b6
	463077 --> 264246
	linkStyle 11 stroke:#b1b1b6
	343045 --> 349329
	linkStyle 12 stroke:#b1b1b6
	907594(["Start"]) --> 737386
	linkStyle 13 stroke:#b1b1b6
	301196 --> 343045
	linkStyle 14 stroke:#b1b1b6
	611854 --> 343045
	linkStyle 15 stroke:#b1b1b6
```

</details>


## License

`Pull Request Tracker` is free and open-source software licensed under the [MIT](./LICENSE.md) License.<br>The icon used is from [Phosphor Icons](https://phosphoricons.com/) licensed under the MIT License.