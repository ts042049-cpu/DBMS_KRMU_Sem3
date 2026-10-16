CREATE TABLE BOOKING (
    Booking_ID INT PRIMARY KEY,
    Cust_ID INT NOT NULL,
    Show_ID INT NOT NULL,
    Booking_Date DATETIME NOT NULL,
    Seat_No INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO BOOKING (Booking_ID, Cust_ID, Show_ID, Booking_Date, Seat_No, Amount) VALUES
(1,  101, 5001, '2026-10-01 10:00:00', 45, 250.00),
(2,  102, 5001, '2026-10-01 10:15:00', 12, 250.00),
(3,  101, 5002, '2026-10-02 14:30:00', 88, 300.00),
(4,  103, 5001, '2026-10-02 16:00:00', 45, 250.00),
(5,  101, 5003, '2026-10-03 18:00:00', 15, 350.00);

CREATE INDEX idx_booking_cust_date ON BOOKING (Cust_ID, Booking_Date DESC);

CREATE INDEX idx_booking_date_show ON BOOKING (Booking_date, Show_ID);

EXPLAIN SELECT Show_ID, Booking_Date, Seat_No, Amount 
FROM BOOKING 
WHERE Cust_ID = 101 
ORDER BY Booking_Date DESC;