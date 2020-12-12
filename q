{
 "metadata": {
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.7.4-final"
  },
  "orig_nbformat": 2,
  "kernelspec": {
   "name": "python3",
   "display_name": "Python 3.7.4 64-bit (conda)",
   "metadata": {
    "interpreter": {
     "hash": "55d852cad6d72cd63413427ae4f5418f84914edf09935ce27cf78d516463fe5a"
    }
   }
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2,
 "cells": [
  {
   "source": [
    "# PASO 1: Extracción de datos\n",
    "Extracción de datos de las correspondientes APIs y fuentes de datos, para recolectar toda la información necesaria utilizamos:\n",
    "\n",
    "    1. Google places APIs.\n",
    "    2. Open data de la Comunidad Autónoma de Madrid.\n",
    "    3.   "
   ],
   "cell_type": "markdown",
   "metadata": {}
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [],
   "source": [
    "import requests #web requests\n",
    "import json #to work with json in py\n",
    "import numpy as np\n",
    "import pandas as pd\n",
    "from time import sleep #wait\n",
    "from urllib.parse import urlencode #consturcts the encoding of ulr"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "metadata": {},
   "outputs": [],
   "source": [
    "import extraccion as ext\n",
    "import extraccion_2 as ext_2\n",
    "# import google"
   ]
  },
  {
   "source": [
    "## Extración desde la API de Google\n",
    "Extracción de información sobre negocios de interés a través de Google Places. Datos: localización, coordenadas, nombre... "
   ],
   "cell_type": "markdown",
   "metadata": {}
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "metadata": {},
   "outputs": [],
   "source": [
    "API_KEY = \"AIzaSyDlFd1hsTHlsFuni7Jmti7WWRBPBRj0-TI\" #Google Maps API-Key\n",
    "\n",
    "#Coordenadas que recuadran el área de búsqueda de locales.\n",
    "lat_1 = 40.442870  \n",
    "lat_2 = 40.402975\n",
    "lon_1 = -3.712643\n",
    "lon_2 = -3.677109\n",
    "\n",
    "place_list = ['restaurant', 'cafe', 'bar']"
   ]
  },
  {
   "source": [
    "### Ejemplo de parámetros de búsqueda para restaurantes en un rango de coordenadas:\n",
    "geometry_params = {\"lats\": [lat_1, lat_2], \"lngs\": [lon_1, lon_2], \"n_lat\": 8, \"n_lng\": 8} #Parámetros geométricos\n",
    "search_params = {\"api_key\": API_KEY, \"placetype\": place_list} # Parámetros de búsqueda\n",
    "filename_list = [\"restaurant\", 'bars', 'cafes'] # Nombre del archivo de salida"
   ],
   "cell_type": "code",
   "metadata": {},
   "execution_count": 4,
   "outputs": []
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "metadata": {},
   "outputs": [],
   "source": [
    "sth = ext_2.extraction(geometry_params, search_params, filename_list)\n",
    "sth"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "metadata": {},
   "outputs": [],
   "source": [
    "geometry = ext.define_search_geometry(lats= geometry_params['lats'], lngs= geometry_params['lngs'], n_lat= 8, n_lng= 8)\n",
    "# geometry"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "metadata": {},
   "outputs": [],
   "source": [
    "restaurant = ext.url_gen(api_key= search_params['api_key'], coordinates= geometry['coordinates'], radius= geometry['radius'], placetype= search_params['placetype'][0], output= 'json')\n",
    "\n",
    "cafe = ext.url_gen(api_key= search_params['api_key'], coordinates= geometry['coordinates'], radius= geometry['radius'], placetype= search_params['placetype'][1], output= 'json')\n",
    "\n",
    "bar = ext.url_gen(api_key= search_params['api_key'], coordinates= geometry['coordinates'], radius= geometry['radius'], placetype= search_params['placetype'][2], output= 'json')\n"
   ]
  },
  {
   "source": [
    "def extraction (geometry_params, search_params, filename_list):\n",
    "    \"\"\"\n",
    "    ---What it does---\n",
    "        + Generates a url from a given latitude and altitude for restaurants, bars and cafes in the area. Then makes a Google API request and generates a json file.\n",
    "    ---What it needs---\n",
    "        + geometry_params: a dictionary of latitude and altitude parameters.\n",
    "        + search_params: a dictionary of search parameters. MUST contain:\n",
    "            + 'api_key': API_KEY\n",
    "            + 'placetype': place_list\n",
    "    ---What it returns---\n",
    "        + json files.\n",
    "    \"\"\"\n",
    "    #Functions\n",
    "    def distance_calculation(point1, point2):\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Calculates the distance between two coordenates in kms, having into account latitude and longitude.\n",
    "        ---What it needs---\n",
    "            + point1: list with 2 elements, latitude and longitude.\n",
    "            + point2: list with 2 elements, latitude and longitude.\n",
    "            IMPORTANT! keep attention in the format in which points are described.\n",
    "        ---What it returns---\n",
    "            + distance: in kms.\n",
    "        \"\"\"\n",
    "        r = 6373.0 #Earth's radius in Kms\n",
    "        \n",
    "        lat1, lng1 = radians(float(point1[0])), radians(float(point1[1])) #Reshaping of coordenates from polar units to radianes\n",
    "        lat2, lng2 = radians(float(point2[0])), radians(float(point2[1]))\n",
    "        \n",
    "        dlon = lng2 - lng1 \n",
    "        dlat = lat2 - lat1\n",
    "        \n",
    "        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2 #Distance estimation, Kms\n",
    "        c = 2 * atan2(sqrt(a), sqrt(1 - a))\n",
    "        distance = r * c\n",
    "        return distance\n",
    "\n",
    "    def define_search_geometry(lats, lngs, n_lat = 8, n_lng = 8):\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            Creates the grid search.\n",
    "        ---What it needs---\n",
    "            + lats: A list of 2 elements containing latitude coordinates.\n",
    "            + long: A list of 2 elements containing longitude coordinates.\n",
    "            + n_lat: 8 by default\n",
    "            + n_lng: 8 by default\n",
    "            IMPORTANT! keep attention in the format in which points are described.\n",
    "        ---What it returns---\n",
    "            + geometry: a dictionary of 2 entries, coordinates(contains coordinates list of 2 elements), radius (radius of search).\n",
    "        \"\"\"\n",
    "\n",
    "        lat1, lat2 = lats[0], lats[1]  #Geometry of latitudes\n",
    "        lat_separation = (lat2 - lat1)/n_lat\n",
    "        lat_geometry = np.array(lat1) + (np.arange(n_lat) + 0.5) * lat_separation\n",
    "        \n",
    "        lng1, lng2 = lngs[0], lngs[1] #Geometry of longitudes\n",
    "        lng_separation = (lng2 - lng1)/n_lng\n",
    "        lng_geometry = np.array(lng1) + (np.arange(n_lng) + 0.5) * lng_separation\n",
    "        \n",
    "        coordinates = [(lat, lng) for lat in lat_geometry for lng in lng_geometry] #Resulting geometry: Borehole coordinates and radius\n",
    "        \n",
    "        lat_sep_distance = distance_calculation([lat1, lng1], [lat1 + lat_separation, lng1])\n",
    "        lng_sep_distance = distance_calculation([lat1, lng1], [lat1, lng1 + lng_separation])\n",
    "        radius = sqrt(lat_sep_distance**2 + lng_sep_distance**2)/2 * 1000\n",
    "        \n",
    "        geometry = {\"coordinates\": coordinates, \"radius\": radius}\n",
    "        return geometry\n",
    "\n",
    "    def url_gen(api_key, coordinates, radius, placetype, output = \"json\"):\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Generates the URL to obtained the data.\n",
    "        ---What it needs---\n",
    "            + api_key: personal token for the access to the API.\n",
    "            + coordinates: geometric parameter for the search.\n",
    "            + radius: geometric parameter for the search.\n",
    "            + output = format of the file in where data are obtained\n",
    "        ---What it returns---\n",
    "            + geometry.\n",
    "        \"\"\"\n",
    "\n",
    "        endpoint = f\"https://maps.googleapis.com/maps/api/place/nearbysearch/{output}\" #Endpoint generation\n",
    "        \n",
    "        #Generation and encoding of parameters\n",
    "        parameters = {\"key\": api_key, \n",
    "                    \"location\": f\"{coordinates[0]}, {coordinates[1]}\", \n",
    "                    \"radius\": radius,\n",
    "                    \"type\": placetype}\n",
    "        url_parameters = urlencode(parameters)\n",
    "        url = f\"{endpoint}?{url_parameters}\" #Creation of url for access\n",
    "        return url\n",
    "\n",
    "    def get_url(url):\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Executes the access to the url.\n",
    "        ---What it needs---\n",
    "            + url.\n",
    "        ---What it returns---\n",
    "            + json files.\n",
    "        \"\"\"\n",
    "        r = requests.get(url)\n",
    "        return r.json()\n",
    "\n",
    "    def write_json(filename_list, json_data): #Update the content of a file and enter information in json format \n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Update the content of a file and enter information in json format.\n",
    "        ---What it needs---\n",
    "            + filename_list.\n",
    "        \"\"\"\n",
    "        for i in range(0, len(filename_list)):\n",
    "            with open(filename_list[i], \"a\") as file:\n",
    "                file.write(json.dumps(json_data))\n",
    "                file.write(\"\\n\\n\")    \n",
    "\n",
    "    def read_json(filename_list): #Opens and reads a json file\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Opens and reads the json files.\n",
    "        ---What it needs---\n",
    "            + url.\n",
    "        ---What it returns---\n",
    "            + json files.\n",
    "        \"\"\"\n",
    "        for i in range(0, len(filename_list)):\n",
    "            with open(filename_list[i], \"r\") as file:\n",
    "                json_data = file.read()\n",
    "            return json.loads(json_data)\n",
    "\n",
    "    def search_nearby_places(api_key, coordinates, radius, placetype, filename_list, output = \"json\"):\n",
    "        \"\"\"\n",
    "        ---What it does---\n",
    "            + Opens and reads the json files.\n",
    "        ---What it needs---\n",
    "            + url.\n",
    "        ---What it returns---\n",
    "            + json files.\n",
    "        \"\"\"\n",
    "        for i in range(0, len(filename_list)):\n",
    "            url = url_gen(api_key, coordinates, radius, filename_list[i], output = \"json\") #Generación de la dirección url   \n",
    "            rjson = get_url(url) \n",
    "            write_json(filename_list[i], rjson)\n",
    "        \n",
    "        while \"next_page_token\" in rjson.keys(): #Check if the is next pages available and if so, it include them\n",
    "            sleep(2) #Necesary wait for correct funcionatily of the fuction\n",
    "            rjson = get_url(url + f\"&pagetoken={rjson['next_page_token']}\")\n",
    "            write_json(filename_list[i], rjson)\n",
    "    \n",
    "    #Execution phase 1: definition of the geometrical parameters\n",
    "    geometry = define_search_geometry(lats = geometry_params[\"lats\"], lngs = geometry_params[\"lngs\"], n_lat = geometry_params[\"n_lat\"], n_lng = geometry_params[\"n_lng\"])\n",
    "\n",
    "    #Execution phase 2: extraction of the desired information of the nearby places\n",
    "    for i in range(len(geometry[\"coordinates\"])): \n",
    "        for j in range(len(filename_list)):\n",
    "            search_nearby_places(api_key = search_params[\"api_key\"], \n",
    "                             coordinates = geometry[\"coordinates\"][i], \n",
    "                             radius = geometry[\"radius\"], \n",
    "                             placetype = search_params[\"placetype\"], \n",
    "                             filename_list = filename_list[j], \n",
    "                             output = \"json\")    "
   ],
   "cell_type": "code",
   "metadata": {},
   "execution_count": 7,
   "outputs": []
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "metadata": {},
   "outputs": [
    {
     "output_type": "error",
     "ename": "TypeError",
     "evalue": "extraction() got an unexpected keyword argument 'lats'",
     "traceback": [
      "\u001b[1;31m---------------------------------------------------------------------------\u001b[0m",
      "\u001b[1;31mTypeError\u001b[0m                                 Traceback (most recent call last)",
      "\u001b[1;32m<ipython-input-8-3daaa7f21247>\u001b[0m in \u001b[0;36m<module>\u001b[1;34m\u001b[0m\n\u001b[1;32m----> 1\u001b[1;33m \u001b[0mextraction\u001b[0m\u001b[1;33m(\u001b[0m\u001b[0mlats\u001b[0m\u001b[1;33m=\u001b[0m \u001b[0mgeometry_params\u001b[0m\u001b[1;33m[\u001b[0m\u001b[1;34m'lats'\u001b[0m\u001b[1;33m]\u001b[0m\u001b[1;33m,\u001b[0m \u001b[0mlngs\u001b[0m\u001b[1;33m=\u001b[0m \u001b[0mgeometry_params\u001b[0m\u001b[1;33m[\u001b[0m\u001b[1;34m'lngs'\u001b[0m\u001b[1;33m]\u001b[0m\u001b[1;33m,\u001b[0m \u001b[0mn_lat\u001b[0m\u001b[1;33m=\u001b[0m \u001b[1;36m8\u001b[0m\u001b[1;33m,\u001b[0m \u001b[0mn_lng\u001b[0m\u001b[1;33m=\u001b[0m \u001b[1;36m8\u001b[0m\u001b[1;33m)\u001b[0m\u001b[1;33m\u001b[0m\u001b[1;33m\u001b[0m\u001b[0m\n\u001b[0m",
      "\u001b[1;31mTypeError\u001b[0m: extraction() got an unexpected keyword argument 'lats'"
     ]
    }
   ],
   "source": [
    "extraction(lats= geometry_params['lats'], lngs= geometry_params['lngs'], n_lat= 8, n_lng= 8)"
   ]
  }
 ]
}
