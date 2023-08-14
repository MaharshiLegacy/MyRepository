import React, { useEffect, useState } from "react";
import Loding from "./Loding";
import NewsItems from "./NewsItems";

export default function NewsComponent(props) {
  // this are diffrent states for our news app.

  // Article array
  const [article, setArticle] = useState([]);
  // loding state
  const [loading, setLoading] = useState(true);
  // current page
  const [page, setPage] = useState(1);
  // total page based on page size and total articles
  const [totalpage, settotalPage] = useState(1);
  // for disable the next and previous buttons 
  const [count, setCount] = useState(1);

  // run when component is mounted componentDidMount
  const un = async () => {
    let url = `https://newsapi.org/v2/top-headlines?country=${props.country}&category=${props.category}&apiKey=a12d2428939446a5b46fe6a3282027f3&pageSize=${props.pageSize}&page=${page}`;
    let pr = await fetch(url);
    let pr2 = await pr.json();
    console.log(pr2);
    setArticle(pr2.articles);
    setLoading(false);
    setPage(1);
    settotalPage(pr2.totalResults / props.pageSize);
    setCount(pr2.totalResults / props.pageSize);
  };
  //only when component mount's
  // like componentDidMount() in class Based component
  useEffect(() => {
    console.log("useEffect")
    un();
    // eslint-disable-next-line 
  },[]);

  const nextPage = async () => {
    let url = `https://newsapi.org/v2/top-headlines?country=${
      props.country
    }&category=${
      props.category
    }&apiKey=a12d2428939446a5b46fe6a3282027f3&pageSize=${props.pageSize}&page=${
      page + 1
    }`;
    setLoading(true);
    let pr = await fetch(url);
    let pr2 = await pr.json();
    console.log(pr2);

    setArticle(pr2.articles);
    setLoading(false);
    setPage(page + 1);
    settotalPage(totalpage - 1);
    setCount(pr2.totalResults / props.pageSize);
  };
  const previousPage = async () => {
    let url = `https://newsapi.org/v2/top-headlines?country=${
      props.country
    }&category=${
      props.category
    }&apiKey=a12d2428939446a5b46fe6a3282027f3&pageSize=${props.pageSize}&page=${
      page - 1
    }`;
    setLoading(true);

    let pr = await fetch(url);
    let pr2 = await pr.json();
    console.log(pr2);

    setArticle(pr2.articles);
    setLoading(false);
    setPage(page - 1);
    settotalPage(totalpage + 1);
    setCount(pr2.totalResults / props.pageSize);
  };

  return (
    <>
      <div className="container my-3">
        <h2 className="text-center my-3">NewsMonyey Top Headlines</h2>
        {loading && <Loding />}
        <div className="row">
          {!loading &&
            article.map((element) => {
              return (
                <div key={element.url} className="col-md-4 my-2" id="card-item">
                  <NewsItems
                    urlToImage={
                      element.urlToImage
                        ? element.urlToImage
                        : "https://picsum.photos/200"
                    }
                    title={element.title ? element.title.slice(0, 50) : ""}
                    description={
                      element.description
                        ? element.description.slice(0, 73)
                        : ""
                    }
                    url={element.url}
                    author={element.author}
                    date={element.publishedAt}
                    source={element.source.name}
                  />
                </div>
              );
            })}
        </div>
      </div>
      <div className="container d-flex justify-content-between my-3">
        <button
          disabled={totalpage === count}
          type="button"
          className="btn btn-dark"
          onClick={previousPage}
        >
          Previous
        </button>
        <button
          disabled={totalpage < 1}
          type="button"
          className="btn btn-dark"
          onClick={nextPage}
        >
          Next
        </button>
      </div>
    </>
  );
}
NewsComponent.defaultProps = {
  country: "in",
  category: "general",
  pageSize: 5,
};
