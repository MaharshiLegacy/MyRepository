import React from "react";
import NavBar from "./components/NavBar";
import NewsComponent from "./components/NewsComponent";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
export default function App(){
    return (
      <Router>
        <NavBar />
        <Routes>
          <Route
            path="/business"
            element={
              <NewsComponent key="business" pageSize={20} country="in" category="business" />
            }
          />
          <Route
            path="/entertainment"
            element={
              <NewsComponent key="entertainment"
                pageSize={20}
                country="in"
                category="entertainment"
              />
            }
          />
          <Route
            path="/general"
            element={
              <NewsComponent key="general" pageSize={20} country="in" category="general" />
            }
          />
          <Route
            path="/health"
            element={
              <NewsComponent key="health" pageSize={20} country="in" category="health" />
            }
          />
          <Route
            path="/science"
            element={
              <NewsComponent key="science" pageSize={20} country="in" category="science" />
            }
          />
          <Route
            path="/sports"
            element={
              <NewsComponent key="sports" pageSize={20} country="in" category="sports" />
            }
          />
          <Route
            path="/technology"
            element={
              <NewsComponent key="technology" pageSize={20} country="in" category="technology" />
            }
          />
        </Routes>
      </Router>
    );
  }

