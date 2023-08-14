import React from "react";

export default function NewsItems (props){
    return (
        <div className="card" >
          <span class="position-absolute top-0 translate-middle badge rounded-pill bg-danger" style={{left:"90%",zIndex:"1"}}>
    {props.source}
  </span>
          <img src={props.urlToImage} className="card-img-top" alt="..." style={{height:"300px"}} />
          <div className="card-body">
            <h5 className="card-title">{props.title+"..."}</h5>
            <p className="card-text">
             {props.description+"..."}
            </p>
            <p class="card-text"><small class="text text-danger">By {props.author} on {new Date(props.date).toUTCString()}</small></p>
            <a href={props.url} target="_blank" className="btn btn-dark">
              Read More
            </a>
          </div>
        </div>
    );
  }
