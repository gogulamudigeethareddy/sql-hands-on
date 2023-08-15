INSERT INTO public.aircraft_code(code, "aircraft_name")
VALUES ('ZW','Air Wisconsin');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('AS','Alaska Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('G4','Allegiant Air LLC');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('AA','American Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('C5','Champlain Air');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('CP','Compass Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('DL','Delta Air Lines, Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('EM','Empire Airline');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('9E','Endeavor Air');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('MQ','Envoy Air');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('EV','ExpressJet Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('F9','Frontier Airlines, Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('G7','GoJet Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('HA','Hawaiian Airlines Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('QX','Horizon Air');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('B6','JetBlue Airways Corporation');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('OH','Jetstream Intl');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('YV','Mesa Airlines, Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('KS','Penair');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('PT','Piedmont Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('YX','Republic Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('OO','Skywest Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('WN','Southwest Airlines');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('NK','Spirit Airlines, Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('AX','TransState');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('UA','United Airlines, Inc.');
INSERT INTO public.aircraft_code(code, "aircraft_name")
	VALUES ('AU','August Airlines, Inc.');


ALTER TABLE aircraft_code ADD COLUMN id SERIAL PRIMARY KEY;

SELECT MIN(id), code, aircraft_name
FROM public.aircraft_code
GROUP BY id;

DELETE FROM public.aircraft_code ac
WHERE ac.id >= 27;

