# Get News Bash Script
Gets news from https://newsapi.org/ 
One Paragraph of project description goes here

## Getting Started
Go to https://newsapi.org/docs/get-started and get an API key. 

### Prerequisites

What things you need to install the software and how to install them

```
awk
curl
jq
sed
```

### Installing

```
git clone https://github.com/fhenriquez/getnews_bash.git
```

Edit the getnews.sh to add the news_apiKey variable.


## Usage
```
Usage: getnews <news-id> [options]
Description:    The script will gather the top headlines for a giving news source.

required arguments:
<news-id>    News id.

optional arguments:
-a|--all    List all sources.
-d|--desc    <news-id> Get descriptor.
-l|--list    List all English speaking news sources.
-h|--help    Show this help message and exit.
-i|--id        List all English speaking news sources id.
-s|--source    <news-id> List all articles of the news source.
-t|--top    <news-id> List the top headlines of the news source.
-u|--url    Print URL of news articles from source.
``` 

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning


## Authors

* **Franklin Henriquez** - *Initial work* - [fhenriquez](https://github.com/fhenriquez)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

