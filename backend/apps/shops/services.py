import math

EARTH_RADIUS_KM = 6371.0088


def haversine_distance_km(latitude_1, longitude_1, latitude_2, longitude_2):
    lat1 = math.radians(float(latitude_1))
    lon1 = math.radians(float(longitude_1))
    lat2 = math.radians(float(latitude_2))
    lon2 = math.radians(float(longitude_2))

    delta_lat = lat2 - lat1
    delta_lon = lon2 - lon1

    a = (
        math.sin(delta_lat / 2) ** 2
        + math.cos(lat1) * math.cos(lat2) * math.sin(delta_lon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return EARTH_RADIUS_KM * c
