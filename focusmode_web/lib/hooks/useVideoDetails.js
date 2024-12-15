import Fetch from "../fetch";
import { useEffect, useState } from "react";
import getYtId from "../getYtId";

const useVideoData = async ({ ytVidId }) => {
  const [data, setData] = useState(null);
  const getLocalStorageVideo = (key) => {
    const item = localStorage.getItem("video:" + key);
    if (item) {
      return JSON.parse(item);
    }
  };
  const setLocalStorageVideo = (key, value) => {
    localStorage.setItem("video:" + key, JSON.stringify(value));
  };

  const handleVideoData = async () => {
    const videoId = getYtId(ytVidId);
    if (!videoId) {
      return;
    }
    const videoCache = getLocalStorageVideo(videoId);
    if (videoCache) {
      console.log("Found video in cache:", videoCache);
      return videoCache;
    }
    const data = await Fetch({
      endpoint: `/api/db/video/${videoId}`,
      method: "GET",
    });
    setLocalStorageVideo(videoId, data);
    console.log("Found video:", data);
    return data;
  };
  useEffect(() => {
    handleVideoData().then((data) => {
      setData(data);
    });
  }, [ytVidId]);
  if (!data)
    return {
      video: {
        title: "",
      },
    };

  return {
    video: data,
  };
};

export default useVideoData;
