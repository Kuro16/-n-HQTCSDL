--Huỳnh Gia Huy (3/5/2023) tạo database
create database HQTCSDL

use HQTCSDL
go

--Huỳnh Gia Huy (3/5/2023) tạo bảng thông tin sân bay 
create table Airport(
	AirportID nvarchar(3) primary key, -- (Mã sân bay) ràng buộc khóa chính cho mã sân bay
	AirportName nvarchar(150) unique  not null, -- (Tên sân bay) ràng buộc tên sân bay là duy nhất 
	AirportLocation nvarchar(150)  not null --(Thành phố mà sân bay trực thuộc) Địa điểm
)



-- Huỳnh Gia Huy (3/5/2023) tạo bảng thông tin phân quyền
create table Role(
	RoleID nvarchar(10) primary key, -- (Mã phân quyền) ràng buộc khóa chính cho mã phân quyền
	RoleName nvarchar(50) not null, -- (Quyền truy cập)
	AccessLevel nvarchar(50) not null -- (Mức độ truy cập)
)




-- Huỳnh Gia Huy (3/5/2023) tạo bảng lưu trữ thông tin tài khoản
create table Account(
	Email nvarchar(255) primary key, --(Email) ràng buộc khóa chính cho email
	Password nvarchar(50) not null, -- (Mật khẩu)
	RoleID nvarchar(10) not null, --(Mã phân quyền)
	FirstName nvarchar(50) not null, -- (Họ)
	LastName nvarchar(50) not null, -- (Tên)
	Phone varchar(20) unique not null, --(Số điện thoại) ràng buộc số điện thoại là duy nhất
	ID nvarchar(15) unique not null, -- (căn cước công dân) ràng buộc căn cước công dân là duy nhất

	-- kiểm tra email ở dạng hợp lệ 
	constraint CK_EMAIL check (Email LIKE '%@gmail.com'),

	--kiểm tra mật khẩu phải từ 9 ký tự và không được quá 50 ký tự
	constraint CK_PASS check (Password <= 9 and Password <= 50 ),

	-- kiểm tra số điện thoại phù hợp ở VN
	constraint CK_PHONE check (Phone LIKE '0[235789][0-9]{8,9}' OR Phone LIKE '0[2469][0-9]{8}') ,

	-- tham chiếu khóa ngoại đến thực thể Role
	constraint FK_AC_R foreign key (RoleID) references Role(RoleID),
)





-- Huỳnh Gia Huy (3/5/2023) tạo bảng phân quyền cho account 
create table RoleAccount (
	Email nvarchar(255), -- (email được phân quyền)
	RoleID nvarchar(10), -- (mã phân quyền)

	-- ta sử dụng khóa chính kết hợp cho bảng này 
	primary key (Email, RoleID),

	-- tham chiếu khóa ngoại đến thực thể Role
	constraint FK_RA_R foreign key (RoleID) references Role(RoleID),

	-- tham chiếu khóa ngoại đến thực thể Account
	constraint FK_RA_A foreign key (Email) references Account(Email),
)




-- Huỳnh Gia Huy (3/5/2023) tạo bảng lưu trữ thông tin chuyến bay
create table Flights(
	FLightID nvarchar(10) primary key, --(Mã chuyến bay) ràng buộc khóa chính cho thuộc tính này
	DepartureID nvarchar(3) not null, -- (Mã sân bay khởi hành)
 	ArriveID nvarchar(3) not null, -- (Mã sân bay hạ cánh)
	DepartureDate date not null, -- (ngày khởi hành)
	DepartureTime time not null, -- (giờ khởi hành)
	ArriveDate date not null, -- (ngày hạ cánh)
	ArriveTime time not null, -- (giờ hạ cánh)
	FlightHours int not null, -- (giờ bay)
	FlightMinutes int not null, -- (phút bay)
	PriceTicket decimal(10,2) not null, --(giá vé máy bay)

	-- kiểm tra giờ khởi hành và giờ hạ cánh phải phù hợp 
	constraint CK_ARRTIME check (ArriveTime > DepartureTime),

	-- kiểm tra giờ bay hợp lệ
	constraint CK_HOURS check (FlightHours > 0),

	-- kiểm tra phút bay hợp lệ
	constraint CK_MIN check (FlightMinutes >=0 and FlightMinutes <=60),

	-- kiểm tra chuyến bay tránh bị trùng 
	constraint CK_UNIQUE_FLIGHT unique (DepartureID,ArriveID,DepartureDate,DepartureTime,ArriveTime),

	-- tham chiếu khóa ngoại đến thực thể Airport
	constraint FK_AF_DEP foreign key (DepartureID) references Airport(AirportID),
	constraint FK_AF_ARR foreign key (ArriveID) references Airport(AirportID),
)

-- Huỳnh Gia Huy (4/5/2023) tạo bảng lưu trữ thông tin chi tiết chuyến bay 
create table FLightDetail(
	FDetailID nvarchar(10) primary key, -- (mã chi tiết chuyến bay ) ràng buộc khóa chính cho thuộc tính này
	FLightID nvarchar(10) not null, --(mã chuyến bay)
	TransitAirport nvarchar(3), --(mã sân bay trung gian) có thể null
	TransitTime time, -- (Thời gian dừng nếu có trạm trung gian) 
	Note text, -- (Ghi chú)

	-- tham chiếu khóa ngoại đến thực thể Flights
	constraint FK_FD_F foreign key (FLightID) references Flights(FlightID),

	-- tham chiếu khóa ngoại đến thực thể Airport
	constraint FK_FD_A foreign key (TransitAirport) references Airport(AirportID)
)


-- Huỳnh Gia Huy (4/5/2023) tạo bảng lưu trữ thông tin ưu đãi
create table Voucher (
	VoucherID nvarchar(10) primary key, --(Mã voucher) đặt khóa chính cho thuộc tính này 
	Rate int not null, --(phần trăm ưu đãi	)
	EffectiveDate date not null, --(Ngày hiệu lực)
	ExpiryDate date not null, -- (Ngày hết hiệu lực)

	-- ta có ràng buộc về ngày hiệu lực 
	--phải sau ngày hiện tại 
	CHECK (EffectiveDate >= GETDATE()),

	-- và ngày hết hiệu lực phải sau ngày hiệu lực 
	CHECK (ExpiryDate > EffectiveDate)
)



-- Huỳnh Gia Huy (4/5/2023) tạo bảng lưu trữ thông tin đặt đơn vé 
create table OrderTicket(
	OrderID nvarchar(10) primary key, -- (Mã đơn vé) đặt khóa chính cho thuộc tính này 
	FlightID nvarchar(10) not null, -- (Mã chuyến bay)
	Quantity int not null, --(số lượng hành khách)
	Email nvarchar(255) not null, --(email người đặt vé)
	Status nvarchar(50) not null , --(Trạng thái của đơn vé)
	Total decimal(10,2) not null, -- (Tổng tiền chưa bao gồm giảm giá)


	-- tham chiếu khóa ngoại đến thực thể FLights 
	constraint FK_O_F foreign key (FlightID) references Flights(FlightID),

	-- tham chiếu khóa ngoại đến thực thể Account
	constraint FK_O_A foreign key (Email) references Account(Email),
)


-- Huỳnh Gia Huy (4/5/2023) tạo bảng lưu thông tin hành khách của chuyến bay
create table Passengers(
	PassengerID nvarchar(10) primary key, --(mã hành khách) đặt khóa chính cho thuộc tính này 
	FlightID nvarchar(10) not null, --(mã chuyến bay)
	OrderID nvarchar(10) not null, -- (mã đặt vé)
	PFirstName nvarchar(50) not null, -- (họ hành khách)
	PLastName nvarchar(50) not null, -- (tên hành khách)
	DOB date not null, -- (ngày sinh)
	Gender nvarchar(10) not null, --(giới tính )
	Country nvarchar(150) not null, -- (quốc tịch)
	ID nvarchar(50) unique not null, -- (căn cước công dân ) ràng buộc duy nhất cho căn cước để tránh trùng lặp hành khách

	-- tham chiếu khóa ngoại đến thực thể OrderTicket
	constraint FK_P_O foreign key (OrderID) references OrderTicket(OrderID),

	--tham chiếu khóa ngoại đến thực thể Flights 
	constraint FK_P_F foreign key (FlightID) references Flights(FlightID)

)

-- Huỳnh Gia Huy (4/5/2023) tạo bảng lưu thông tin hóa đơn sau khi thanh toán 
create table Bill (
	BillID nvarchar(10) primary key, --(mã hóa đơn) đặt khóa chính cho thuộc tính này
	OrderID nvarchar(10) unique not null, -- (mã đặt vé) ràng buộc duy nhất cho thuộc tính này để tránh trùng lặp 
	Date datetime NOT NULL DEFAULT GETDATE(), -- (ngày xuất hóa đơn) đặt giá trị mặc định cho ngày xuất hóa đơn là ngày hiện tại
	Email nvarchar(255) not null, --(email thanh toán)
	Quantity int not null, --(số lượng vé)
	Price decimal(10,2) not null, -- (giá mỗi vé)
	VoucherID nvarchar(10) not null, -- (mã giảm giá )
	TotalPrice decimal(10,2) not null, -- (tổng tiền đã bao gồm mã giảm giá)

	-- tham chiếu khóa ngoại đến thực thể OrderTicket
	constraint FK_B_O foreign key (OrderID) references OrderTicket(OrderID),

	--tham chiếu khóa ngoại đến thực thể Account
	constraint FK_B_A foreign key (Email) references Account(Email),

	--tham chiếu khóa ngoại đến thực thể Voucher
	constraint FK_B_V foreign key (VoucherID) references Voucher(VoucherID)
)



-- Huỳnh Gia Huy (4/5/2023) tạo thực thể lưu trữ thông tin vé chuyến bay 
create table Tickets(
	TicketID nvarchar(10) primary key , -- (mã vé) đặt khóa chính cho thuộc tính này
	BillID nvarchar(10) not null, -- (mã hóa đơn)
	PassengerID nvarchar(10) unique not null, -- (mã hành khách) ràng buộc duy nhất cho thuộc tính này
	PFirstName nvarchar(50) not null, -- (họ hành khách)
	PLastName nvarchar(50) not null, -- (tên hành khách)
	FlightID nvarchar(10) not null, -- (mã chuyến bay )
	DepartureDate date not null, -- (ngày khởi hành)
	DapartureTime time not null, --(giờ khởi hành)
	DepartureID nvarchar(3) not null, -- (sân bay khởi hành)
	ArriveID nvarchar(3) not null , -- (sân bay hạ cánh)
		

	-- tham chiếu khóa ngoại đến thực thể Airport
	constraint FK_T_AP_DEP foreign key (DepartureID) references Airport(AirportID),
	constraint FK_T_AP_ARR foreign key (ArriveID) references Airport(AirportID)

)


-- Huỳnh Gia Huy (4/5/2023) tạo thực thể lưu thông tin doanh thu 
create table Revenue(
	DayRevenue int not null, -- (ngày thống kê)
	MonthRevenue int not null, -- (tháng thống kê)
	YearRevenue int  not null, -- (năm thống kê)
	NumOfTicket int not null, -- (tổng số vé đã bán)
	TotalRevenue decimal(10,2) not null, -- (tổng doanh thu)
	Profit decimal(10,2) not null, -- (tổng lợi nhuận)

	-- kiểm tra ngày hợp lệ
	constraint CK_DAY check (DayRevenue > 1 and DayRevenue <=31),

	--kiểm tra tháng hợp lệ
	constraint CK_MONTH check (MonthRevenue >=1 and MonthRevenue <=12),

	--kiểm tra năm hợp lệ 
	constraint CK_YEAR check (YearRevenue between 2000 and 9999),

	-- ta dùng khóa chính kết hợp cho 3 thuộc tính Day Month và Year
	primary key (DayRevenue, MonthRevenue ,YearRevenue)
)

-- Huỳnh Gia Huy (4/5/2023) tạo thực thể lưu thông tin Yêu cầu hủy vé 
create table CancelTicket(
	Email nvarchar(255) not null, --(email yêu cầu)
	OrderID nvarchar(10) not null, -- (mã đơn vé yêu cầu)
	Reason nvarchar(400) not null, -- (lý do)
	Status nvarchar(150) not null, -- (trạng thái)

	-- ta sử dụng khóa chính kết hợp cho hai thuộc tính Email và OrderID
	primary key (Email, OrderID),

	-- tham chiếu khóa ngoại đến thực thể OrderTicket
	constraint FK_CT_O foreign key (OrderID) references OrderTicket(OrderID),

	-- tham chiếu khóa ngoại đến thực thể Account
	constraint FK_CT_AC foreign key (Email) references Account(Email)
)





